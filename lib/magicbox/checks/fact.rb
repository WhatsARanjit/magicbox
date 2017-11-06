module Magicbox::Checks
  class Fact < Magicbox::Check
    def parse
      begin
        code  = URI.unescape(@data['code']).chomp
        fact  = @data['fact'].is_a?(String) ? URI.unescape(@data['fact']).chomp : @data['fact']
        value = @data['value'].is_a?(String) ? URI.unescape(@data['value']).chomp : @data['value']
        require 'facter'
        Facter.clear
        eval(code)
        exitstatus = Facter.value(fact) == value ? 0 : 1
      rescue RuntimeError => e
        {
          'exitcode' => 1,
          'message'  => [e.message],
        }.to_json
      else
        {
          'exitcode' => exitstatus,
          'message' => [
            "expected: #{value}",
            "actual: #{Facter.value(fact)}",
          ].flatten(1)
        }.to_json
      end
    end
  end
end
