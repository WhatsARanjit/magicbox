require 'tempfile'

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

@web = Magicbox::Webserver.new

# Embed pages for iframes
%w[
  syntax/hello_world
  syntax/querying_the_system
  syntax/modifying_attributes
  syntax/observe_your_change
  syntax/validating_your_syntax
].each do |endpoint|
  @web.sample_ui(endpoint, true)
end

# Sample UI pages
%w[
  index
  validate
  fact
  function
  resource
  compile
  apply
].each do |endpoint|
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

api_check('validate', %w[validate])
api_check('fact', %w[validate fact], 'lang' => 'ruby')
api_check('function', %w[validate function], 'lang' => 'ruby')
api_check('resource', %w[resource])
api_check('compile', %w[validate compile], 'lang' => 'puppet')
api_check('apply', %w[validate apply], 'lang' => 'puppet')

@web.run!
