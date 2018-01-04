require 'sinatra/base'

# Magicbox::Webserver class wraps Sinatra::Base
class MyApp < Sinatra::Base; end

class Magicbox::Webserver
  def initialize(
    scope   = nil,
    bind    = '0.0.0.0',
    port    = 8443,
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
    parts = endpoint.split(File::SEPARATOR)
    # Filename of page to load
    fendp = parts.pop
    # Update URI to / if index
    # Add embed_ if embedded page true
    endarr = Array(fendp == 'index' ? '' : fendp)
    subdir = parts
    endarr.unshift(File.join(*parts)) unless parts.empty?

    # Choose URI and header based on whether embedded or not
    header = embed ? :embed_header : :header
    MyApp.get "/#{endarr.join('/')}" do
      # Bring in scope for ERBs
      @scope = MyApp.settings.scope

      # Construct HTML from ERBs
      html  = erb header
      html += erb File.join(*subdir, fendp).to_sym
      html += erb :footer
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
    MyApp.set :scope, @scope
    MyApp.set :static, true
    MyApp.set :views, 'pages'
    MyApp.set :public_folder, 'assets'
    MyApp.set :static_cache_control, [:public, max_age: 60 * 60 * 24]
    MyApp.set :protection, except: :frame_options
  end
end
