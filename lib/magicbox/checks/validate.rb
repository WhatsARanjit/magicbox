module Magicbox::Checks
  class Validate < Magicbox::Check
    def parse
      begin
        code = Magicbox::Webserver.sanitize(@data['code'])
        lang = Magicbox::Webserver.sanitize(@data['lang'])
        tempp = Tempfile.new('pp')
        tempp.write(code)
        tempp.rewind
        tempp.close
        case lang
        when 'puppet'
          cmd = `puppet parser validate #{tempp.path} --color=false 2>&1`
        when 'ruby'
          cmd = `ruby -c #{tempp.path} 2>&1`
        when 'yaml'
          cmd = `ruby -ryaml -e "YAML.load_file '#{tempp.path}'" 2>&1`
        when 'json'
          cmd = `ruby -rjson -e "JSON.parse(File.read('#{tempp.path}'))" 2>&1`
        else
          raise "'#{lang}' is an unsupported language."
        end
        exitstatus = $?.exitstatus
      rescue RuntimeError => e
        {
          'exitcode' => 2,
          'message'  => [e.message],
        }
      else
        {
          'exitcode' => exitstatus,
          'message'  => cmd.split("\n"),
        }
      ensure
        tempp.unlink
      end
    end
  end
end
