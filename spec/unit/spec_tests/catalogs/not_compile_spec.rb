require 'spec_helper'

spec_template = 'it { should_not compile }'

subject = Magicbox::SpecTests::Catalog.new(
  'not_compile',
  {}
)

describe 'not_compile spec_test' do
  it 'should return test' do
    expect(subject.make_spec).to eql(spec_template)
  end
end
