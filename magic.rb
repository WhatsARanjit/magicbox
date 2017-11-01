require 'tempfile'
require_relative './lib/magicbox/webserver.rb'

web = Magicbox::Webserver.new
[
  'index',
  'validate',
  'fact',
].each do |endpoint|
  web.sample_ui(endpoint)
end

web.post 'validate' do
  content_type :json
  request.body.rewind
  begin
    data  = JSON.parse(request.body.read)
    code  = URI.unescape(data['code']).chomp
    lang  = data['lang'].chomp
    tempp = Tempfile.new('pp')
    tempp.write(code)
    tempp.rewind
    tempp.close
    case lang
    when 'puppet'
      parse = %x(puppet parser validate #{tempp.path} --color=false 2>&1)
    when 'ruby'
      parse = %x(ruby -c #{tempp.path} 2>&1)
    when 'yaml'
      parse = %x(ruby -ryaml -e "YAML.load_file '#{tempp.path}'" 2>&1)
    when 'json'
      parse = %x(ruby -rjson -e "JSON.parse(File.read('#{tempp.path}'))" 2>&1)
    else
      raise "'#{lang}' is an unsupported language."
    end
    exitstatus = $?.exitstatus
  rescue => e
    { "exitcode" => 1, "message" => [e.message]}.to_json
  else
    { "exitcode" => exitstatus, "message" => parse.split("\n")}.to_json
  ensure
    tempp.unlink
  end
end

web.post 'fact' do
  content_type :json
  request.body.rewind
  begin
    data  = JSON.parse(request.body.read)
    code  = URI.unescape(data['code']).chomp
    fact  = data['fact'].chomp
    value = data['value'].is_a?(String) ? URI.unescape(data['value']).chomp : data['value']
    require 'facter'
    Facter.clear
    parse = eval(code).value
    exitstatus = parse == value ? 0 : 1
  rescue => e
    { "exitcode" => 1, "message" => [e.message]}.to_json
  else
    { "exitcode" => exitstatus, "message" => ["expected: #{value}", "actual: #{parse}"].flatten(1)}.to_json
  end
end

web.run!
