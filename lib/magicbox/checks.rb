module Magicbox
  class Check
    def initialize(data)
      @data = data
    end

    attr_reader :data

    # Placeholder method
    def parse
      {}.to_json
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/spec_tests/base.rb')
require File.expand_path(File.dirname(__FILE__) + '/checks/validate.rb')
require File.expand_path(File.dirname(__FILE__) + '/checks/fact.rb')
require File.expand_path(File.dirname(__FILE__) + '/checks/function.rb')
require File.expand_path(File.dirname(__FILE__) + '/checks/resource.rb')
