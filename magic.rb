require 'tempfile'

module Magicbox; end

require File.expand_path(File.dirname(__FILE__) + '/lib/magicbox/webserver.rb')
require File.expand_path(File.dirname(__FILE__) + '/lib/magicbox/checks.rb')

web = Magicbox::Webserver.new
%w[
  index
  validate
  fact
  function
  function_args
  resource
  compile
  parser_validate
  apply
  hello_world
].each do |endpoint|
  web.sample_ui(endpoint)
end

web.post 'validate' do
  content_type :json
  request.body.rewind
  raw   = JSON.parse(request.body.read)
  check = Magicbox::Checks::Validate.new(raw)
  check.http_response
end

web.post 'fact' do
  content_type :json
  request.body.rewind
  raw    = JSON.parse(request.body.read)
  data   = raw.merge({ 'lang' => 'ruby' })
  check1 = Magicbox::Checks::Validate.new(data)
  result = check1.http_response
  if result.first != 200
    result
  else
    check2 = Magicbox::Checks::Fact.new(raw)
    check2.http_response
  end
end

web.post 'function' do
  content_type :json
  request.body.rewind
  raw    = JSON.parse(request.body.read)
  data   = raw.merge({ 'lang' => 'ruby' })
  check1 = Magicbox::Checks::Validate.new(data)
  result = check1.http_response
  if result.first != 200
    result
  else
    check2 = Magicbox::Checks::Function.new(raw)
    check2.http_response
  end
end

web.post 'resource' do
  content_type :json
  request.body.rewind
  raw   = JSON.parse(request.body.read)
  check = Magicbox::Checks::Resource.new(raw)
  check.http_response
end

web.post 'compile' do
  content_type :json
  request.body.rewind
  raw    = JSON.parse(request.body.read)
  data   = raw.merge({ 'lang' => 'puppet', })
  check1 = Magicbox::Checks::Validate.new(data)
  result = check1.http_response
  if result.first != 200
    result
  else
    check2 = Magicbox::Checks::Compile.new(raw)
    check2.http_response
  end
end

web.post 'apply' do
  content_type :json
  request.body.rewind
  raw   = JSON.parse(request.body.read)
  check = Magicbox::Checks::Apply.new(raw)
  check.http_response
end

web.run!
