require 'tempfile'
require File.expand_path(File.dirname(__FILE__) + '/lib/magicbox/webserver.rb')
require File.expand_path(File.dirname(__FILE__) + '/lib/magicbox/checks.rb')

web = Magicbox::Webserver.new
[
  'index',
  'validate',
  'fact',
  'function',
].each do |endpoint|
  web.sample_ui(endpoint)
end

web.post 'validate' do
  content_type :json
  request.body.rewind
  check = Magicbox::Checks::Validate.new(JSON.parse(request.body.read))
  check.parse
end

web.post 'fact' do
  content_type :json
  request.body.rewind
  check = Magicbox::Checks::Fact.new(JSON.parse(request.body.read))
  check.parse
end

web.post 'function' do
  content_type :json
  request.body.rewind
  check = Magicbox::Checks::Function.new(JSON.parse(request.body.read))
  check.parse
end

web.run!
