class Magicbox::Check
  def initialize(data)
    @data = data
  end

  attr_reader :data

  def resheaders
    {
      'Access-Control-Allow-Origin' => '*'
    }
  end

  def http_response
    resobj    = parse
    http_code =
      case resobj['exitcode']
      when 0
        200
      when 1
        400
      else
        500
      end

    [http_code, resheaders, resobj.to_json]
  end

  # Placeholder method
  def parse
    {}.to_json
  end
end

require File.expand_path(File.dirname(__FILE__) + '/spec_tests/base.rb')
require File.expand_path(File.dirname(__FILE__) + '/checks/validate.rb')
require File.expand_path(File.dirname(__FILE__) + '/checks/fact.rb')
require File.expand_path(File.dirname(__FILE__) + '/checks/function.rb')
require File.expand_path(File.dirname(__FILE__) + '/checks/resource.rb')
require File.expand_path(File.dirname(__FILE__) + '/checks/compile.rb')
