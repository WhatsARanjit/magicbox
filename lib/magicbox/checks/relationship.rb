module Magicbox::Checks
  class Relationship < Magicbox::Checks::Base
    def parse
      begin
        code          = Magicbox::Webserver.sanitize(@data['code'])
        relationships = Magicbox::Webserver.sanitize(@data['relationships'])
        spec          = @data['spec'] || nil

        t = Magicbox::SpecTests::Catalog.new(
          spec,
          {
            relationships: relationships,
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
                    [json.dig('examples', 0, 'status')]
                  else
                    json['examples'].map { |x| x['description'] if x.key?('exception') }.compact
                  end
        {
          'exitcode' => exitstatus,
          'message'  => message,
        }
      end
    end
  end
end
