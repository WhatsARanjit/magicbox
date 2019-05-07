module Magicbox::Checks
  class Resourcecounter < Magicbox::Checks::Base
    def parse
      begin
        require 'json'
        require 'net/http'
        require 'uri'
        @server      = Magicbox::Webserver.sanitize(@data['tfe_server'])      || 'app.terraform.io'
        @api_version = Magicbox::Webserver.sanitize(@data['tfe_api_version']) || 'v2'
        @token       = Magicbox::Webserver.sanitize(@data['tfe_token'])
        @org         = Magicbox::Webserver.sanitize(@data['tfe_org'])
        @type        = Magicbox::Webserver.sanitize(@data['type'])
        @total       = 0
        @now         = Time.now

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

          def tfe_call(endpoint, method = 'GET', data = {}, e_codes = [200, 204])
            http_call(
              method,
              "https://#{@server}/api/#{@api_version}/#{endpoint}",
              data,
              e_codes
            )
          end

          def get_state_url(id)
            get_state_url = tfe_call("workspaces/#{id}/current-state-version", 'GET', {}, [200, 204, 404])
            begin
              JSON.parse(get_state_url)['data']['attributes']['hosted-state-download-url']
            rescue StandardError
              'null'
            end
          end

          def get_targets(state)
            JSON.parse(state)['modules'].map do |m|
              resources = m['resources']
              resources.map { |r, attr| r if attr['type'] == @type }.compact
            end.flatten
          end
        end

        # Get workspaces
        get_workspace_list = tfe_call("organizations/#{@org}/workspaces")
        workspace_list     = JSON.parse(get_workspace_list)['data']

        json_ret = []
        workspace_list.each do |ws|
          # Breakdown ID and name
          id   = ws['id']
          name = ws['attributes']['name']
          ws_ret = {
            id => {
              'name' => name,
            },
          }

          # Get state URL if it exists
          state_url               = get_state_url(id)
          ws_ret[id]['state_url'] = state_url

          # Check for statefile
          if state_url == 'null'
            count = 0
          else
            # Grab state from URL
            get_state = http_call('GET', state_url, {}, [200, 204])
            # Filter for target resource type
            targets = get_targets(get_state)
            # Handle empty variable and count
            if targets.empty?
              count = 0
            else
              ws_ret[id]['targets'] = targets
              count                 = targets.length
            end
          end
          ws_ret[id]['count'] = count

          # Add to return array
          json_ret << ws_ret
          # Incrememt total
          @total += count
        end

        exitstatus     = 0
        ret            = json_ret << {
          'timestamp'    => @now,
          'organization' => @org,
          'workspaces'   => workspace_list.length,
          'type'         => @type,
          'total'        => @total,
        }
      rescue RuntimeError => e
        {
          'exitcode' => 2,
          'message'  => [e.message],
        }
      else
        {
          'exitcode' => exitstatus,
          'message'  => ret.to_json.split("\n")
        }
      end
    end
  end
end
