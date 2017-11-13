require 'yaml'

# Constants
PROJECT_ROOT = __dir__
LIB_ROOT     = File.join(PROJECT_ROOT, 'lib', 'magicbox')
module Magicbox; end

%w[
  webserver.rb
  checks/base.rb
  spec_tests/base.rb
].each do |lib|
  require File.join(LIB_ROOT, lib)
end

# Read config
@config = YAML.load_file('config.yaml')
@web    = Magicbox::Webserver.new(@config)

# Embed pages for iframes
@config['embedded_pages'].each do |endpoint|
  @web.sample_ui(endpoint, true)
end

# Sample UI pages
@config['sample_pages'].each do |endpoint|
  @web.sample_ui(endpoint)
end

def api_check(endpoint, checks, add_data = {})
  @web.post endpoint do
    content_type :json
    request.body.rewind
    raw  = JSON.parse(request.body.read)
    # Merge any necessary fields
    data = raw.merge(add_data)
    # Stack the checks
    res  = checks.reduce([200, {}, '']) do |memo, check|
      response_code = memo.first
      if response_code == 200
        check = Object.const_get("Magicbox::Checks::#{check.capitalize}").new(data)
        check.http_response
      else
        memo
      end
    end
    res
  end
end

@config['checks'].each do |endpoint, options|
  options['merge'] ||= {}
  api_check(endpoint, options['checks'], options['merge'])
end

@web.run!
