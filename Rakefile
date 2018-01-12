require 'yaml'
require 'json'

# Read config.yaml
config = YAML.load_file('config.yaml')['webserver'] || {}

def build_docker(options)
  build     = "#{options['title']}:#{options['version']}"
  cmd_array = %W[
    docker image build
    --build-arg
    protocol=#{options['protocol']},port=#{options['port']}
    -t #{build} .
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

def build_beanstalk(options)
  FileUtils.mkdir('build') unless Dir.exist?('build')
  build     = "#{options['title']}-#{options['version']}.zip"
  cmd_array = %W[
    zip
    #{File.join('build', build)}
    -r *
    -x build/\\* scripts/\\* spec/\\* vendor/\\* keys/\\* README.md LICENSE
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
task :docker, [:options] do |_t, args|
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
  options['title']    ||= 'magicbox'
  options['protocol'] ||= config.key?('ssl_enable') && config['ssl_enable'] == true ? 'https' : 'http'
  options['port']     ||= config['port'] || 8443
  options['version']  ||= config['version'] || '0.1'

  puts "INFO: Image title: #{options['title']}"
  puts "INFO: Protocol: #{options['protocol']}"
  puts "INFO: Port: #{options['port']}"
  puts "INFO: Version: #{options['version']}"

  build_docker(options)
end

desc 'Build a Magic Box application into a Beanstalk app'
task :beanstalk, [:options] do |_t, args|
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
  options['title']    ||= 'magicbox'
  options['version']  ||= config['version'] || '0.1'

  puts "INFO: Image title: #{options['title']}"
  puts "INFO: Version: #{options['version']}"

  build_beanstalk(options)
end
