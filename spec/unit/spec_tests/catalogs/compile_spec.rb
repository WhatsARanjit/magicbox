require 'spec_helper'

spec_template = 'it { should compile }'

subject = Magicbox::SpecTests::Share.new(
  'compile',
  {}
)

describe 'compile spec_test' do
  it 'should return test' do
    expect(subject.make_spec).to eql(spec_template)
  end
end
