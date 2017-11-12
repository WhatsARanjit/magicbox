# Constants
PROJECT_ROOT = File.expand_path('..', File.dirname(__FILE__))
LIB_ROOT     = File.join(PROJECT_ROOT, 'lib', 'magicbox')
module Magicbox; end

%w[
  webserver.rb
  checks/base.rb
  spec_tests/base.rb
].each do |lib|
  require File.join(LIB_ROOT, lib)
end

RSpec.configure do |c|
  c.formatter = 'documentation'
end
