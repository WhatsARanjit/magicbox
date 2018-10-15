module Magicbox::Checks
  class Json2hcl < Magicbox::Checks::Base
    def parse
      begin
        require 'json'
        require 'rhcl'
        code = Magicbox::Webserver.sanitize(@data['code'])
        lang = Magicbox::Webserver.sanitize(@data['lang'])
        case lang
        when 'json'
          parsed = Rhcl.parse(code)
          ret    = JSON.pretty_generate(parsed)
        when 'hcl'
          parsed = JSON.parse(code)
          ret    = Rhcl.dump(parsed)
        else
          raise "'#{lang}' is an unsupported language."
        end
        exitstatus = 0
      rescue RuntimeError => e
        {
          'exitcode' => 2,
          'message'  => [e.message],
        }
      else
        {
          'exitcode' => exitstatus,
          'message'  => ret.split("\n"),
        }
      end
    end
  end
end
