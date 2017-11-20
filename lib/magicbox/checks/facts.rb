module Magicbox::Checks
  class Facts < Magicbox::Checks::Base
    def parse
      begin
        fact = Magicbox::Webserver.sanitize(@data['fact'])

        require 'facter'
        result = (
          if !fact.empty?
            Facter.value(fact)
          else
            JSON.pretty_generate(Facter.to_hash)
          end
        )

        exitstatus = result.empty? ? 1 : 0
      rescue RuntimeError => e
        {
          'exitcode' => 2,
          'message'  => [e.message],
        }
      else
        {
          'exitcode' => exitstatus,
          'message'  => [result],
        }
      end
    end
  end
end
