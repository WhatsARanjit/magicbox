module Magicbox::Checks
  class Tfecall < Magicbox::Checks::Base
    def parse
      begin
        require 'json'
        require 'net/http'
        require 'uri'
        @server      = Magicbox::Webserver.sanitize(@data['tfe_server']) || 'app.terraform.io'
        @api_version = Magicbox::Webserver.sanitize(@data['tfe_api_version']) || 'v2'
        @token       = Magicbox::Webserver.sanitize(@data['tfe_token'])
        @method      = Magicbox::Webserver.sanitize(@data['method']) || 'GET'
        @endpoint    = Magicbox::Webserver.sanitize(@data['endpoint'])
        @e_codes     = Magicbox::Webserver.sanitize(@data['e_codes']) || [200, 204]
        @keys        = Magicbox::Webserver.sanitize(@data['keys']) || {}

        class << self
          def http_call(method, url, data, e_codes)
            uri  = URI(url)
            http = Net::HTTP.new(uri.host, uri.port)

            http.use_ssl     = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE

            req                  = Net::HTTP.const_get(method.capitalize).new(uri.request_uri)
            req.body             = data.to_json
            req.content_type     = 'application/vnd.api+json'
            req['Authorization'] = "Bearer #{@token}"

            res = http.request(req)

            raise res.body unless e_codes.include? res.code.to_i
            res.body
          end
        end

        ret = http_call(
          @method,
          "https://#{@server}/api/#{@api_version}/#{@endpoint}",
          @keys,
          @e_codes
        )
      rescue RuntimeError => e
        {
          'exitcode' => 2,
          'message'  => [e.message],
        }
      else
        {
          'exitcode' => 0,
          'message'  => JSON.parse(ret)['data'],
        }
      end
    end
  end
end
