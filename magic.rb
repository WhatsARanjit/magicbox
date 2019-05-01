require 'yaml'
require 'webrick'
require 'webrick/https'

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

# Read config
@config = YAML.load_file(File.join(PROJECT_ROOT, 'config.yaml'))
@web    = Magicbox::Webserver.new(@config)

# Webserver options
w_opts                      = @config['webserver']
@woptions                   = { app: MyApp }
@woptions[:Host]            = w_opts['host'] if w_opts.key?('host')
@woptions[:Port]            = w_opts['port'] if w_opts.key?('port')
@woptions[:Logger]          = w_opts['logger'] if w_opts.key?('logger')
@woptions[:SSLEnable]       = w_opts['ssl_enable'] if w_opts.key?('ssl_enable')
@woptions[:SSLVerifyClient] = w_opts['ssl_verify_client'] if w_opts.key?('ssl_verify_client')
@woptions[:SSLCertName]     = w_opts['ssl_certname'] if w_opts.key?('ssl_certname')
@woptions[:SSLCertificate]  = OpenSSL::X509::Certificate.new(File.read(w_opts['ssl_certificate'])) if w_opts.key?('ssl_certificate')
@woptions[:SSLPrivateKey]   = OpenSSL::PKey::RSA.new(File.read(w_opts['ssl_private_key'])) if w_opts.key?('ssl_private_key')

# Embed pages for iframes
if @config.key?('embedded_pages')
  @config['embedded_pages'].each do |endpoint|
    @web.sample_ui(endpoint, true)
  end
end

# Sample UI pages
if @config.key?('sample_pages')
  @config['sample_pages'].each do |endpoint|
    @web.sample_ui(endpoint)
  end
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

@config['checks'].each do |endpoint, options|
  options['merge'] ||= {}
  api_check(endpoint, options['checks'], options['merge'])
end

# @web.run!
# Don't start app if called by Passenger
if caller.empty?
  Rack::Server.start @woptions
else
  Rack::Server.start @woptions unless File.basename(caller(1..1).first).match(/config\.ru/) == true
end
