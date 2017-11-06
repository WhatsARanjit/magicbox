require 'sinatra/base'

# Magicbox::Webserver class wraps Sinatra::Base
class MyApp < Sinatra::Base; end

class Magicbox::Webserver
  def initialize(
    bind    = '0.0.0.0',
    port    = 80,
    version = '1.0'
  )
    @bind    = bind
    @port    = port
    @version = version

    setup_webserver
  end

  attr_reader :version

  def self.sanitize(input)
    if input.is_a?(String)
      # '+' manually replaced to URL code
      URI.decode_www_form_component(input.gsub(/\+/, '%2B'))
    else
      input
    end
  end

  def post(endpoint, &block)
    MyApp.post(api(endpoint), &block)
  end

  def bind
    MyApp.bind(@bind)
  end

  def sample_ui(endpoint)
    endp = endpoint == 'index' ? '' : endpoint
    MyApp.get "/#{endp}" do
      html  = File.read './pages/header.html'
      html += File.read "./pages/#{endpoint}.html"
      html += File.read './pages/footer.html'
      html
    end
  end

  def run!
    MyApp.run!
  end

  private

  def api(endpoint)
    "/api/#{@version}/#{endpoint}"
  end

  def setup_webserver
    MyApp.set :port, @port
    MyApp.set :bind, @bind
    MyApp.set :static, true
    MyApp.mime_type :js, 'application/javascript'
    MyApp.mime_type :css, 'text/css'
    MyApp.mime_type :png, 'image/png'
    MyApp.mime_type :json, 'application/json'
    MyApp.mime_type :ico, 'image/x-icon'
    MyApp.mime_type :fonts, 'application/x-font-woff'
    MyApp.get '/assets/*/*' do
      type = params['splat'][0]
      file = params['splat'][1]
      content_type type.to_sym
      File.read "./assets/#{type}/#{file}"
    end
  end
end
