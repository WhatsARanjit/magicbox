module Magicbox::Checks
  class Resource < Magicbox::Check
    def parse
      begin
        code  = URI.unescape(@data['code']).chomp
        m     = code.match(/^puppet resource ([\w\_\d]+) ?['"]?(.*)/)
        raise 'Could not understand code' unless m
        type  = m[1]
        title = m[2].empty? ? false : m[2]
        raise 'Could not find type' unless type

        # Check command against optional type and title
        checks = Array.new
        _type  = @data['type'].is_a?(String) ? URI.unescape(@data['type']).chomp : @data['type']
        _title = @data['title'].is_a?(String) ? URI.unescape(@data['title']).chomp : @data['title']

        checks << "Supplied type '#{type}' does not match '#{_type}'" if _type and _type != type
        checks << "Supplied title '#{title}' does not match '#{_title}'" if _title and _title != title

        if checks.empty?
          require 'puppet/indirector/face'

          if title
            cmd_out = Puppet::Face[:resource, '0.0.1'].find("#{type}/#{title}")
            message = [cmd_out.to_manifest]
          else
            cmd_out = Puppet::Face[:resource, '0.0.1'].search(type)
            message = cmd_out.collect { |r| r.to_manifest }
          end

          if cmd_out.empty?
            exitstatus = 1
            message    = ['Could not find matching resource(s).']
          else
            exitstatus = 0
          end
        else
          exitstatus = 1
          message    = checks
        end

      rescue => e
        { "exitcode" => 1, "message" => [e.message] }.to_json
      else
        { "exitcode" => exitstatus, "message" => message }.to_json
      end
    end
  end
end