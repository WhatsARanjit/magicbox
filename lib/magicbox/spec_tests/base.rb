module Magicbox::SpecTests
  class Base
    def initialize(named_spec, opts)
      @spec = named_spec
      @opts = opts

      # Create scope for template
      opts.each do |k, v|
        instance_variable_set("@#{k}", v)
      end

      @spec_file = @spec.split('_').reduce('') { |memo, part| "#{memo}#{part.capitalize}" }

      load_spec
    end

    attr_reader :spec, :opts

    # Method will return raw spec contents
    def make_spec
      klass = Object.const_get("Magicbox::SpecTests::#{spec_type.capitalize}::#{@spec_file}")
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
        require File.join(LIB_ROOT, 'spec_tests', spec_type, "#{@spec}.rb")
      rescue LoadError
        raise "Unable to load 'spec_tests/#{spec_type}/#{@spec}.rb'"
      end
    end
  end
end

Dir[File.join(LIB_ROOT, 'spec_tests', '*.rb')].each do |check|
  require check
end
