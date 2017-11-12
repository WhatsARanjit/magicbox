module Magicbox::Checks
  class Resource < Magicbox::Checks::Base
    def parse
      begin
        code = Magicbox::Webserver.sanitize(@data['code'])
        typ  = Magicbox::Webserver.sanitize(@data['type'])
        titl = Magicbox::Webserver.sanitize(@data['title'])
        m    = code.match(/^puppet resource ([\w\_\d]+) ?['"]?(.*)/)

        # Optional params
        munge  = Magicbox::Webserver.sanitize(@data['munge'])
        filter = Magicbox::Webserver.sanitize(@data['filter'])

        raise 'Could not understand code' unless m
        type  = m[1]
        title = m[2].empty? ? false : m[2]
        raise 'Could not find type' unless type

        # Check command against optional type and title
        checks = []
        checks << "Supplied type '#{type}' does not match '#{typ}'" if typ && typ != type
        checks << "Supplied title '#{title}' does not match '#{titl}'" if titl && titl != title

        if checks.empty?
          require 'puppet/indirector/face'

          if title
            poutput = Puppet::Face[:resource, '0.0.1'].find("#{type}/#{title}")
            # Overwrite any parameters
            if munge
              new_resource_hash = poutput.to_h
              munge.each do |attr, value|
                new_resource_hash[attr.to_sym] = value
              end
              poutput = Puppet::Resource.from_data_hash(
                'type'       => typ,
                'title'      => titl,
                'parameters' => new_resource_hash
              )
            end
            # Filter returned parameters
            if filter
              new_resource_hash = {}
              filter.each do |attr|
                new_resource_hash[attr.to_sym] = poutput[attr.to_sym] if poutput[attr.to_sym]
              end
              poutput = Puppet::Resource.from_data_hash(
                'type'       => typ,
                'title'      => titl,
                'parameters' => new_resource_hash
              )
            end
            message = [poutput.to_manifest]
          else
            poutput = Puppet::Face[:resource, '0.0.1'].search(type)
            message = poutput.collect(&:to_manifest)
          end

          if poutput.empty?
            exitstatus = 1
            message    = ['Could not find matching resource(s).']
          else
            exitstatus = 0
          end
        else
          exitstatus = 1
          message    = checks
        end
      rescue RuntimeError => e
        {
          'exitcode' => 2,
          'message'  => [e.message],
        }
      else
        {
          'exitcode' => exitstatus,
          'message'  => message,
        }
      end
    end
  end
end
