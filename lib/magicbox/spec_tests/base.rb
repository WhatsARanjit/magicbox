module Magicbox
  module Spec_tests
    class Base
      def initialize(named_spec, opts)
        @spec = named_spec
        @opts = opts

        #@function_args = opts.dig(:function_args)
        #@value         = opts.dig(:value)
        # Create scope for template
        opts.each do |k,v|
          instance_variable_set("@#{k.to_s}", v)
          attr_accessor :"#{k.to_s}"
        end

        load_spec
      end

      attr_reader :spec, :opts

      # Method will return raw spec contents
      def make_spec
        klass = Object.const_get("Magicbox::Spec_tests::#{spec_type.capitalize}::#{@spec.capitalize}")
        klass.make_spec(*opts)
      end

      private

      # Placeholder methods
      # This is used to set directory in load path
      def spec_type
        ''
      end

      # Method will load spec based on asked name
      def load_spec
        begin
          require File.expand_path(File.dirname(__FILE__) + "/#{spec_type}/#{@spec}.rb")
        rescue LoadError => e
          raise "Unable to load 'spec_tests/#{spec_type}/#{@spec}.rb'"
        end
      end
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/sandbox.rb')
require File.expand_path(File.dirname(__FILE__) + '/shared.rb')
require File.expand_path(File.dirname(__FILE__) + '/functions.rb')
