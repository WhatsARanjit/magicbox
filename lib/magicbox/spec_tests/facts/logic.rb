module Magicbox::SpecTests::Facts
  class Logic
    def self.make_spec(*opts)
      opts_hash  = opts.to_h
      facts_hash = opts_hash[:facts_hash]

      spec_array = ['describe \'magic_module\', :type => :class do']

      facts_hash.each do |f, v|
        v.each do |value, check|
          context = <<-"CONTEXT"
            context 'when #{f} is "#{value}"' do
              let :facts do
                { #{f}: '#{value}' }
              end

              it { is_expected.to contain_#{check['type']}('#{Magicbox::Webserver.sanitize(check['title'])}') }
            end
          CONTEXT

          spec_array << context
        end
      end

      spec_array << 'end'
      spec_array.join("\n")
    end
  end
end
