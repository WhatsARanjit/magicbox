require 'sinatra'
require 'json'
require 'tempfile'
require 'uri'

set :bind, '0.0.0.0'
set :static, true
@v = '1.0'

def api(endpoint)
 "/api/#{@v}/#{endpoint}"
end

def sample_ui(endpoint)
  _endpoint = endpoint == 'index' ? '' : endpoint
  get "/#{_endpoint}" do
    html  = File.read "./pages/header.html"
    html += File.read "./pages/#{endpoint}.html"
    html += File.read "./pages/footer.html"
    html
  end
end

configure do
  mime_type :js, 'application/javascript'
  mime_type :css, 'text/css'
  mime_type :png, 'image/png'
  mime_type :json, 'application/json'
  mime_type :ico, 'image/x-icon'
end

[
'index',
'validate',
'fact',
].each do |endpoint|
  sample_ui(endpoint)
end

get '/assets/*/*' do
  type = params['splat'][0]
  file = params['splat'][1]
  content_type type.to_sym
  File.read "./assets/#{type}/#{file}"
end

post api('validate') do
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

post api('fact') do
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
