module Magicbox::Checks
  class Tfecall < Magicbox::Checks::Base
    def parse
      begin
        require 'json'
        require 'net/http'
        require 'uri'
        @server      = Magicbox::Webserver.sanitize(@data['tfe_server']) || 'app.terraform.io'
        @api_prefix  = Magicbox::Webserver.sanitize(@data['api_prefix']) || 'api'
        @api_version = Magicbox::Webserver.sanitize(@data['tfe_api_version']) || 'v2'
        @token       = Magicbox::Webserver.sanitize(@data['tfe_token'])
        @method      = Magicbox::Webserver.sanitize(@data['method']) || 'GET'
        @endpoint    = Magicbox::Webserver.sanitize(@data['endpoint'])
        @e_codes     = Magicbox::Webserver.sanitize(@data['e_codes']) || [200, 204]
        @keys        = Magicbox::Webserver.sanitize(@data['keys']) || {}
        @return_key  = Magicbox::Webserver.sanitize(@data['return_key']) || 'data'

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

        # Construct URL
        url = [
          "https://#{@server}",
          @api_prefix,
          @api_version,
          @endpoint
        ].join('/')

        raw = http_call(
          @method,
          url,
          @keys,
          @e_codes
        )

        # Get the link data for pagination
        link_data = JSON.parse(raw)["links"]
        ret = @return_key.empty? ? JSON.parse(raw) : JSON.parse(raw)[@return_key]
        while link_data["self"] != link_data["last"]
          next_page = http_call(
            @method,
            link_data["next"],
            @keys,
            @e_codes
          )
          link_data = JSON.parse(next_page)["links"]
          ret.concat(@return_key.empty? ? JSON.parse(next_page) : JSON.parse(next_page)[@return_key])
        end
      rescue RuntimeError => e
        {
          'exitcode' => 2,
          'message'  => [url, e.message, e.backtrace.inspect],
        }
      else
        {
          'exitcode' => 0,
          'message'  => ret,
        }
      end
    end
  end
end
