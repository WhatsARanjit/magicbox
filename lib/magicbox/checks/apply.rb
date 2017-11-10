module Magicbox::Checks
  class Apply < Magicbox::Check
    def parse
      begin
        code  = Magicbox::Webserver.sanitize(@data['code'])
        check = Magicbox::Webserver.sanitize(@data['check'])
        error = Magicbox::Webserver.sanitize(@data['error'])
        tempp = Tempfile.new('pp')
        tempp.write(code)
        tempp.rewind
        tempp.close

        cmd_out    = `puppet apply #{tempp.path} --noop --color=false 2>&1`
        exitstatus = $?.exitstatus
      rescue RuntimeError => e
        {
          'exitcode' => 2,
          'message'  => [e.message],
        }
      else
        check_code = 1
        # Scrub output of noop
        cmd_out_scrubbed = cmd_out.split("\n").map do |line|
          line.gsub!(/ \(noop\)/, '') || line
          line.gsub!(/should be/, 'changed to') || line
          line.gsub!(/Would have (\w)/) do
            Regexp.last_match[1].upcase if Regexp.last_match[1]
          end || line
          if check
            match_pattern = /#{check}/
            check_code    = 0 if line.match(match_pattern)
          end
          line
        end
        # Adjust exitcode to reflect output
        if check
          exitstatus = check_code
          e_message  = error || "Output did not match '#{check}'."
          cmd_out_scrubbed.unshift(e_message) unless exitstatus.zero?
        end
        {
          'exitcode' => exitstatus,
          'message'  => cmd_out_scrubbed,
        }
      ensure
        tempp.unlink
      end
    end
  end
end
