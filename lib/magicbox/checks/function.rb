module Magicbox::Checks
  class Function < Magicbox::Checks::Base
    def parse
      begin
        code          = Magicbox::Webserver.sanitize(@data['code'])
        function_name = Magicbox::Webserver.sanitize(@data['function'])
        function_args = Magicbox::Webserver.sanitize(@data['args'])
        value         = Magicbox::Webserver.sanitize(@data['value'])
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
          spec_test = (
            if function_args.is_a?(String)
              "it { is_expected.to run.with_params(['#{function_args.gsub("'", %q(\\\'))}']).and_return(#{value}) }"
            else
              "it { is_expected.to run.with_params(*#{function_args}).and_return(#{value}) }"
            end
          )
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
          'exitcode' => 2,
          'message'  => [e.message],
        }
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
        }
      end
    end
  end
end
