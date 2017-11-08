module Magicbox::Checks
  class Fact < Magicbox::Check
    def parse
      begin
        code    = Magicbox::Webserver.sanitize(@data['code'])
        fact    = Magicbox::Webserver.sanitize(@data['fact'])
        value   = Magicbox::Webserver.sanitize(@data['value'])
        require 'facter'
        Facter.clear
        eval(code)
        exitstatus = Facter.value(fact) == value ? 0 : 1
      rescue RuntimeError => e
        {
          'exitcode' => 2,
          'message'  => [e.message],
        }
      else
        {
          'exitcode' => exitstatus,
          'message' => [
            "expected: #{value}",
            "actual: #{Facter.value(fact)}",
          ].flatten(1)
        }
      end
    end
  end
end
