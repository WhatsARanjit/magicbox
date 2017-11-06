module Magicbox::Checks
  class Function < Magicbox::Check
    def parse
      begin
        code          = URI.unescape(@data['code']).chomp
        function_name = @data['function'].chomp
        value         = @data['value'].is_a?(String) ? URI.unescape(@data['value']).chomp : @data['value']
        function_args = @data['args'].is_a?(String) ? URI.unescape(@data['args']).chomp : @data['args']
        spec          = @data['spec'] || nil
        if spec
          t = Magicbox::SpecTests::Function.new(
            spec,
            {
              function_args: function_args,
              value: value,
            }
          )
          spec_test = t.make_spec
        else
          spec_test = "it { is_expected.to run.with_params(*#{function_args}).and_return(#{value}) }"
        end

        # Find out v4 or v3 and function name
        m = code.match(/(Puppet::(?:Parser::)?Functions)[:\.]+[\w_]+function\((?:[\\n\s]*):['"]?([\w\d_]+)/)
        raise 'Could not recognize as function' unless m[1]

        api_v   = m[1] == 'Puppet::Functions' ? 4 : 3
        sandbox = Magicbox::SpecTests::Sandbox.new(function_name, "function#{api_v}", code, spec_test)

        # Run and clean
        exitstatus, cmd_out = sandbox.run!
        sandbox.cleanup!
      rescue RuntimeError => e
        {
          'exitcode' => 1,
          'message'  => [e.message],
        }.to_json
      else
        json    = JSON.parse(cmd_out)
        message = if exitstatus.zero?
                    json.dig('examples', 0, 'status')
                  else
                    json.dig('examples', 0, 'exception', 'message')
                  end
        {
          'exitcode' => exitstatus,
          'message'  => [message],
        }.to_json
      end
    end
  end
end
