module Magicbox::Checks
  class Compile < Magicbox::Check
    def parse
      begin
        code      = URI.unescape(@data['code']).chomp
        item      = URI.unescape(@data['item']).chomp
        t         = Magicbox::Spec_tests::Share.new('compile', {})
        spec_test = t.make_spec
        sandbox   = Magicbox::Spec_tests::Sandbox.new(item, 'class', code, spec_test)

        # Run and clean
        exitstatus, cmd_out = sandbox.run!
        sandbox.cleanup!

      rescue => e
        { "exitcode" => 1, "message" => [e.message]}.to_json
      else
        json    = JSON.parse(cmd_out)
        message = exitstatus == 0 ? json.dig('examples', 0, 'status') : json.dig('examples', 0, 'exception', 'message')
        { "exitcode" => exitstatus, "message" => [message]}.to_json
      end
    end
  end
end
