require 'spec_helper'

spec_template = 'it { is_expected.to run.with_params([10, 20]).and_raise_error([ArgumentError, "Error message"]) }'

subject = Magicbox::SpecTests::Function.new(
  'raise_error',
  {
    function_args: [10, 20],
    value: [ArgumentError, 'Error message'],
  }
)

describe 'raise_error spec_test' do
  it 'should return test' do
    expect(subject.make_spec).to eql(spec_template)
  end
end
