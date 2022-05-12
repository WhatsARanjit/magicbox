module Magicbox::Checks
  class Vaultmocks < Magicbox::Checks::Base
    def parse
      begin
        require 'json'
        command = Magicbox::Webserver.sanitize(@data['command'])

        pattern = 'curl -X ([\w]+) (-H ".*")+ -d \'({".*"})\' (https?://[\d\.]+:\d+)/v1(.*)$'
        matches = command.match(pattern)

        operation = {
          'PUT'    => 'create',
          'POST'   => 'update',
          'GET'    => 'read',
          'DELETE' => 'delete'
        }

        ret = JSON.pretty_generate({
          'global' => {
            'request' => {
              'operation' => operation[matches[1]],
              'path'      => matches[5],
              'data'      => matches[3]
            }
          },
          'test' => {
            'main' => true
          }
        })
        exitstatus = 0

      rescue RuntimeError => e
        {
          'exitcode' => 2,
          'message'  => [e.message],
        }
      else
        {
          'exitcode' => exitstatus,
          'message'  => ret.split("\n"),
        }
      end
    end
  end
end
