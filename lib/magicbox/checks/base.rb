module Magicbox::Checks
  class Base
    def initialize(data)
      @data = data
    end

    attr_reader :data

    def resheaders
      {
        'Access-Control-Allow-Origin' => '*'
      }
    end

    def http_response
      resobj    = parse
      http_code =
        case resobj['exitcode']
        when 0
          200
        when 1
          400
        else
          500
        end

      [http_code, resheaders, resobj.to_json]
    end

    # Placeholder method
    def parse
      {}.to_json
    end
  end
end

Dir[File.join(LIB_ROOT, 'checks', '*.rb')].each do |check|
  require check
end
