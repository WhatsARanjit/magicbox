require 'sinatra'
require 'json'
require 'tempfile'
require 'uri'

set :bind, '0.0.0.0'

configure do
  mime_type :js, 'application/javascript'
  mime_type :css, 'text/css'
  mime_type :png, 'image/png'
  mime_type :json, 'application/json'
  mime_type :ico, 'image/x-icon'
end

get '/' do
  File.read './pages/magic.html'
end

get '/assets/*/*' do
  type = params['splat'][0]
  file = params['splat'][1]
  content_type type.to_sym
  File.read "./assets/#{type}/#{file}"
end

post '/scripts/validate.rb' do
  content_type :json
  request.body.rewind
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
  tempp.unlink
  { "exitcode" => exitstatus, "message" => parse.split("\n")}.to_json
end
  
