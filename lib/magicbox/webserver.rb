require 'sinatra/base'

# Magicbox::Webserver class wraps Sinatra::Base
class MyApp < Sinatra::Base; end

class Magicbox::Webserver
  def initialize(
    scope   = nil,
    bind    = '0.0.0.0',
    port    = 80,
    version = '1.0'
  )
    @bind    = bind
    @port    = port
    @version = version
    @scope   = scope

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

  def sample_ui(endpoint, embed = false)
    parts  = endpoint.split(File::SEPARATOR)
    # Filename of page to load
    fendp  = parts.pop
    # Update URI to / if index
    # Add embed_ if embedded page true
    endarr = Array(fendp == 'index' ? '' : fendp)
    endarr.unshift('embed_') if embed
    subdir = parts

    # Choose URI and header based on whether embedded or not
    header_html = embed ? :'embed_header.html' : :'header.html'
    MyApp.get "/#{endarr.join}" do
      # Bring in scope for ERBs
      @scope = MyApp.settings.scope

      # Construct HTML from ERBs
      html  = erb header_html
      html += erb File.join(*subdir, "#{fendp}.html").to_sym
      html += erb :'footer.html'
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
    MyApp.set :views, PROJECT_ROOT + '/pages'
    MyApp.set :scope, @scope
    MyApp.set :protection, except: :frame_options
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
