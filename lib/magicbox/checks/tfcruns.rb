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
            'applied-at'              => 0,
            'apply-queued-at'         => 0,
            'applying-at'             => 0,
            'confirmed-at'            => 0,
            'cost-estimated-at'       => 0,
            'cost-estimating-at'      => 0,
            'discarded-at'            => 0,
            'errored-at'              => 0,
            'plan-queueable-at'       => 0,
            'plan-queued-at'          => 0,
            'planned-and-finished-at' => 0,
            'planned-at'              => 0,
            'planning-at'             => 0,
            'policy-checked-at'       => 0,
            'policy-soft-failed-at'   => 0,
          }
        }
        @goutput    = { 'workspaces' => {} }
        @plot_cache = {}

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

          def tfe_call(workspace_id, page = 1)
            # Only reset if starting from page 1
            if page == 1
              @runs_cache['workspaces'][workspace_id] = {
                'applied-at'              => 0,
                'apply-queued-at'         => 0,
                'applying-at'             => 0,
                'confirmed-at'            => 0,
                'cost-estimated-at'       => 0,
                'cost-estimating-at'      => 0,
                'discarded-at'            => 0,
                'errored-at'              => 0,
                'plan-queueable-at'       => 0,
                'plan-queued-at'          => 0,
                'planned-and-finished-at' => 0,
                'planned-at'              => 0,
                'planning-at'             => 0,
                'policy-checked-at'       => 0,
                'policy-soft-failed-at'   => 0,
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

          def fetch_runs(input, meta, workspace_id)
            # For last (oldest) run on page, if later than end_date, skip to next page
            # Also check that there is a next page
            if Date.parse(input.last['attributes']['created-at']) > @end_date &&
               !meta['pagination']['next-page'].nil?
              raw = JSON.parse(tfe_call(workspace_id, meta['pagination']['next-page']))
              ret = fetch_runs(raw['data'], raw['meta'], workspace_id)
              return ret
            end

            filter_list = @filter.split(',')
            input.each do |run|
              workspace_id = run['relationships']['workspace']['data']['id']

              filter_list.each do |f|
                next unless run['attributes']['status-timestamps'].key?(f)
                next unless Date.parse(run['attributes']['status-timestamps'][f]).between?(@start_date, @end_date)
                # Local totals
                @runs_cache['workspaces'][workspace_id][f] += 1
                @runs_cache['totals'][f]                   += 1
                @goutput['workspaces'][workspace_id][f]     = @runs_cache['workspaces'][workspace_id][f]
                # Plot data
                plot_day                 = Date.parse(run['attributes']['status-timestamps'][f]).strftime('%Y-%m-%d')
                @plot_cache[f]           = {} unless @plot_cache.key?(f)
                @plot_cache[f][plot_day] = @plot_cache[f][plot_day].nil? ? 1 : @plot_cache[f][plot_day] += 1
                # Grand totals if more than one workspace
                next unless @workspace_list.length > 1
                @goutput['totals'][f] = @runs_cache['totals'][f]
              end
            end

            # # For last (oldest) run on the page, if later than start_date, check next page also
            # # Also check that there is a next page
            if Date.parse(input.first['attributes']['created-at']) > @start_date &&
               !meta['pagination']['next-page'].nil?
              raw = JSON.parse(tfe_call(workspace_id, meta['pagination']['next-page']))
              fetch_runs(raw['data'], raw['meta'], workspace_id)
            end
          end
        end

        # Workflow
        @workspace_list = @workspace_id.split(',')
        # Grand totals if more than one workspace
        @goutput['totals'] = {} if @workspace_list.length > 1
        @workspace_list.each do |workspace_id|
          raw = JSON.parse(tfe_call(workspace_id))
          fetch_runs(raw['data'], raw['meta'], workspace_id) unless raw['data'].empty?
        end
        # Add sorted plotting data
        @goutput['plot_data'] = @plot_cache.collect { |f, points| { f => points.sort.to_h } }.reduce({}, :merge)
        ret = [@goutput]
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
