PROJECT_ROOT = File.expand_path('..', File.dirname(__FILE__))

module Magicbox; end

[
  %w[spec_tests base.rb],
  %w[webserver.rb]
].each do |file|
  require File.join(PROJECT_ROOT, 'lib', 'magicbox', *file)
end
