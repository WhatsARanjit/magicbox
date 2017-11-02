module Magicbox::Checks
  class Function < Magicbox::Check
    def parse
      begin
        #api_v        = @data['version'] || 4
        code          = URI.unescape(@data['code']).chomp
        function_name = @data['function']
        value         = @data['value'].is_a?(String) ? URI.unescape(@data['value']).chomp : @data['value']
        function_args = URI.unescape(@data['args'])
        spec_test     = @data['spec'] ?
          URI.unescape(@data['spec']): "it { is_expected.to run.with_params(*#{function_args}).and_return(#{value}) }" 

        spec_test.gsub!(/_FUNCTION_NAME/, function_name)
        spec_test.gsub!(/_VALUE/, value.to_s)
        spec_test.gsub!(/_FUNCTION_ARGS/, function_args.to_s)

        # Find out v4 or v3 and function name
        m = code.match(/(Puppet::(?:Parser::)?Functions)[:\.]+[\w_]+function\((?:[\\n\s]+)?:['"]?([\w\d_]+)/)
        raise 'Could not recognize as function' unless m[1]
        api_v         = m[1] == 'Puppet::Functions' ? 4 : 3

        # Setup temporary dirs
        tmp_dir       = Dir.mktmpdir('magicbox')
        spec_dir      = File.join(tmp_dir, 'spec')
        spec_test_raw = <<-"SPEC"
        require 'puppetlabs_spec_helper/module_spec_helper'

        describe '#{function_name}', :type => :puppet_function do
          #{spec_test}
        end
        SPEC

        case api_v
        when 4
          # Set specifics for Puppet 4 function API
          functions_dir      = File.join(spec_dir, 'fixtures', 'modules', 'magic_module', 'lib', 'puppet', 'functions')
          functions_spec_dir = File.join(spec_dir, 'functions')
        when 3
          # Set specifics for Puppet 3 function API
          functions_dir      = File.join(spec_dir, 'fixtures', 'modules', 'magic_module', 'lib', 'puppet', 'parser', 'functions')
          functions_spec_dir = File.join(spec_dir, 'unit', 'functions')
        end

        # Recursively create directories
        functions_spec_dir.split('/').push(function_name).inject { |memo, part| Dir.mkdir(memo) unless (memo.empty? or File.exist?(memo)); File.join(memo, part) }
        functions_dir.split('/').push(function_name).inject { |memo, part| Dir.mkdir(memo) unless (memo.empty? or File.exist?(memo)); File.join(memo, part) }

        # Write function and spec files
        File.open("#{functions_dir}/#{function_name}.rb", 'w') { |file| file.write(code) }
        File.open("#{functions_spec_dir}/#{function_name}_spec.rb", 'w') { |file| file.write(spec_test_raw) }

        require 'rspec-puppet'
        cmd_out     = Dir.chdir(tmp_dir) {
          %x(rspec --format json)
        }
        exitstatus = $?.exitstatus

        FileUtils.remove_entry_secure(tmp_dir)
      rescue => e
        { "exitcode" => 1, "message" => [e.message]}.to_json
      else
        json    = JSON.parse(cmd_out)
        message = exitstatus == 0 ? json.dig('examples', 0, 'status') : json.dig('examples', 0, 'exception', 'message')
        { "exitcode" => exitstatus, "message" => [message]}.to_json
      end
    end
  end
end
