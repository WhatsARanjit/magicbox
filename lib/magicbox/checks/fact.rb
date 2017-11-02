module Magicbox::Checks
  class Fact < Magicbox::Check
    def parse
    begin
      code  = URI.unescape(@data['code']).chomp
      fact  = @data['fact'].chomp
      value = @data['value'].is_a?(String) ? URI.unescape(@data['value']).chomp : @data['value']
      require 'facter'
      Facter.clear
      parse = eval(code).value
      exitstatus = parse == value ? 0 : 1
    rescue => e
      { "exitcode" => 1, "message" => [e.message]}.to_json
    else
      { "exitcode" => exitstatus, "message" => ["expected: #{value}", "actual: #{parse}"].flatten(1)}.to_json
    end
    end
  end
end
