module Magicbox::SpecTests::Catalogs
  class Relationship
    def self.make_spec(*opts)
      opts_hash      = opts.to_h
      resources_hash = opts_hash[:relationships]

      spec_array = ['describe \'magic_module\', :type => :class do']

      resources_hash.each do |resa, rel|
        m       = resa.match(/(.*)\[(.*)\]/)
        type    = Magicbox::Webserver.sanitize(m[1])
        title   = Magicbox::Webserver.sanitize(m[2])
        resb    = rel.values.first
        matcher = (
          case rel.keys.first
          when 'before'
            'comes_before'
          when 'subscribe'
            'subscribes_to'
          when 'require'
            'requires'
          when 'notify'
            'notifies'
          else
            raise "ERROR: '#{rel.keys.first}' is not a valid matcher"
          end
        )

        context = <<-"CONTEXT"
          it { is_expected.to contain_#{type}('#{title}').that_#{matcher}('#{resb}') }
        CONTEXT

        spec_array << context
      end

      spec_array << 'end'
      spec_array.join("\n")
    end
  end
end
