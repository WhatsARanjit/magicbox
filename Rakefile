require 'yaml'
require 'json'

def build_image(options)
  cmd_array = %W[
    docker image build
    --build-arg
    protocol=#{options['protocol']},port=#{options['port']}
    -t #{options['title']} .
  ]

  puts "INFO: Build command: #{cmd_array.join(' ')}"

  # Build it and stream output
  output = []
  r, io  = IO.pipe
  fork do
    system(cmd_array.join(' '), out: io, err: :out)
  end
  io.close
  r.each_line do |l|
    puts l
    output << l.chomp
  end
end

desc 'Build a Magic Box application into a Docker container'
task :build, [:options] do |_t, args|
  begin
    options = JSON.parse(args[:options])
  rescue TypeError
    puts 'INFO: No build options given...'
    options = {}
  rescue JSON::ParserError => e
    warn "ERROR: #{e.message}"
    exit 1
  else
    puts 'INFO: Parsing build options...'
  end

  # Defaults
  config = YAML.load_file('config.yaml')['webserver'] || {}
  options['title']    ||= 'magicbox'
  options['protocol'] ||= config.key?('ssl_enable') && config['ssl_enable'] == true ? 'https' : 'http'
  options['port']     ||= config['port'] || 8443

  puts "INFO: Image title: #{options['title']}"
  puts "INFO: Protocol: #{options['protocol']}"
  puts "INFO: Port: #{options['port']}"

  build_image(options)
end
