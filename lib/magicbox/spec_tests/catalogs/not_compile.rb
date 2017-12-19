module Magicbox::SpecTests::Catalogs
  class NotCompile
    def self.make_spec
      'it { should_not compile }'
    end
  end
end
