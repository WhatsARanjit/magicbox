require 'tempfile'
require File.expand_path(File.dirname(__FILE__) + '/lib/magicbox/webserver.rb')
require File.expand_path(File.dirname(__FILE__) + '/lib/magicbox/checks.rb')

web = Magicbox::Webserver.new
[
  'index',
  'validate',
  'fact',
  'function',
  'function_args',
].each do |endpoint|
  web.sample_ui(endpoint)
end

web.post 'validate' do
  content_type :json
  request.body.rewind
  raw   = JSON.parse(request.body.read)
  check = Magicbox::Checks::Validate.new(raw)
  check.parse
end

web.post 'fact' do
  content_type :json
  request.body.rewind
  raw   = JSON.parse(request.body.read)
  data   = raw.merge({ 'lang' => 'ruby'})
  check1 = Magicbox::Checks::Validate.new(data)
  result = check1.parse
  if JSON.parse(result)['exitcode'] == 1
    result
  else
    check2 = Magicbox::Checks::Fact.new(raw)
    check2.parse
  end
end

web.post 'function' do
  content_type :json
  request.body.rewind
  raw    = JSON.parse(request.body.read)
  data   = raw.merge({ 'lang' => 'ruby'})
  check1 = Magicbox::Checks::Validate.new(data)
  result = check1.parse
  if JSON.parse(result)['exitcode'] == 1
    result
  else
    check2 = Magicbox::Checks::Function.new(raw)
    check2.parse
  end
end

web.run!
