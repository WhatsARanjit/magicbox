module Magicbox::Checks
  class Factlogic < Magicbox::Checks::Base
    def parse
      begin
        code       = Magicbox::Webserver.sanitize(@data['code'])
        facts_hash = Magicbox::Webserver.sanitize(@data['facts_hash'])
        spec       = @data['spec'] || nil

        t = Magicbox::SpecTests::Fact.new(
          spec,
          {
            facts_hash: facts_hash,
          }
        )
        spec_test = t.make_spec

        sandbox = Magicbox::SpecTests::Sandbox.new('magic_module', 'class', code, spec_test)

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
