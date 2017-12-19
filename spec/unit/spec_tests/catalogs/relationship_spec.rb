require 'spec_helper'

spec_template = "describe 'magic_module', :type => :class do\n          it { is_expected.to contain_File('foo').that_requires('Package[bar]') }\n\nend"

subject = Magicbox::SpecTests::Catalog.new(
  'relationship',
  {
    relationships: {
      'File[foo]' => {
        'require' => 'Package[bar]',
      },
    },
  }
)

describe 'compile spec_test' do
  it 'should return test' do
    expect(subject.make_spec).to eql(spec_template)
  end
end
