module Magicbox::Checks
  class Tfcruns < Magicbox::Checks::Base
    def parse
      begin
        require 'json'
        require 'net/http'
        require 'uri'
        @server       = Magicbox::Webserver.sanitize(@data['tfe_server']) || 'app.terraform.io'
        @api_version  = Magicbox::Webserver.sanitize(@data['tfe_api_version']) || 'v2'
        @token        = Magicbox::Webserver.sanitize(@data['tfe_token'])
        @workspace_id = Magicbox::Webserver.sanitize(@data['workspace_id'])
        @filter       = Magicbox::Webserver.sanitize(@data['filter'])
        @start_date   = Date.parse(Magicbox::Webserver.sanitize(@data['start_date']))
        @end_date     = Date.parse(Magicbox::Webserver.sanitize(@data['end_date']))

        # Variables for population
        @runs_cache = {
          'workspaces' => {},
          'totals'     => {
            'applied-at'        => 0,
            'planned-at'        => 0,
            'cost-estimated-at' => 0,
            'policy-checked-at' => 0
          }
        }
        @goutput = { 'workspaces' => {}, 'totals' => {} }

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

          # TODO: Single workspace call
          def tfe_call(workspace_id, page = 1)
            # Only reset if starting from page 1
            if page == 1
              @runs_cache['workspaces'][workspace_id] = {
                'applied-at'        => 0,
                'planned-at'        => 0,
                'cost-estimated-at' => 0,
                'policy-checked-at' => 0
              }
              @goutput['workspaces'][workspace_id] = {}
            end

            http_call(
              'GET',
              "https://#{@server}/api/#{@api_version}/workspaces/#{workspace_id}/runs?page%5Bnumber%5D=#{page}",
              {},
              [200, 204]
            )
          end

          def fetch_runs(input, meta)
            # For last (oldest) run on page, if later than end_date, skip to next page
            # Also check that there is a next page
            if Date.parse(input.last['attributes']['created-at']) > @end_date &&
               !meta['pagination']['next-page'].nil?
              raw = JSON.parse(tfe_call(@workspace_id, meta['pagination']['next-page']))
              ret = fetch_runs(raw['data'], raw['meta'])
              return ret
            end

            filter_list =
              if @filter == 'ALL'
                ['applied-at', 'planned-at', 'cost-estimated-at', 'policy-checked-at']
              else
                [@filter]
              end

            input.each do |run|
              workspace_id = run['relationships']['workspace']['data']['id']

              filter_list.each do |f|
                next unless run['attributes']['status-timestamps'].key?(f)
                next unless Date.parse(run['attributes']['status-timestamps'][f]).between?(@start_date, @end_date)
                # Local totals
                @runs_cache['workspaces'][workspace_id][f] += 1
                @goutput['workspaces'][workspace_id][f]     = @runs_cache['workspaces'][workspace_id][f]
                # Grand totals
                @runs_cache['totals'][f]  += 1
                @goutput['totals'][f]      = @runs_cache['totals'][f]
              end
            end

            # # For last (oldest) run on the page, if later than start_date, check next page also
            # # Also check that there is a next page
            # if Date.parse(input.first['attributes']['created-at']) > @start_date &&
            #    !meta['pagination']['next-page'].nil?
            #   raw = JSON.parse(tfe_call(@workspace_id, meta['pagination']['next-page']))
            #   fetch_runs(raw['data'], raw['meta'])
            # end

            return @goutput
          end
        end

        # Workflow
        raw = JSON.parse(tfe_call(@workspace_id))
        ret = fetch_runs(raw['data'], raw['meta'])
      rescue RuntimeError => e
        {
          'exitcode' => 2,
          'message'  => [e.message],
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
