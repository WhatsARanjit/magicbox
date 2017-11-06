module Magicbox::Checks
  class Validate
    def initialize(data)
      @data = data
    end

    attr_reader :data

    def parse
      begin
        code  = URI.unescape(@data['code']).chomp
        lang  = @data['lang'].chomp
        tempp = Tempfile.new('pp')
        tempp.write(code)
        tempp.rewind
        tempp.close
        case lang
        when 'puppet'
          cmd = `puppet parser validate #{tempp.path} --color=false 2>&1`
        when 'ruby'
          cmd = `ruby -c #{tempp.path} 2>&1`
        when 'yaml'
          cmd = `ruby -ryaml -e "YAML.load_file '#{tempp.path}'" 2>&1`
        when 'json'
          cmd = `ruby -rjson -e "JSON.parse(File.read('#{tempp.path}'))" 2>&1`
        else
          raise "'#{lang}' is an unsupported language."
        end
        exitstatus = $?.exitstatus
      rescue RuntimeError => e
        {
          'exitcode' => 1,
          'message'  => [e.message],
        }.to_json
      else
        {
          'exitcode' => exitstatus,
          'message'  => cmd.split("\n"),
        }.to_json
      ensure
        tempp.unlink
      end
    end
  end
end
