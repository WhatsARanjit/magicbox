require 'spec_helper'

output = '{"exitcode":0,"message":["passed"]}'

subject = Magicbox::Checks::Function.new(
  {
    'args'     => '10%2C25',
    'code'     => 'Puppet%3A%3AFunctions.create_function%28%3Asum%29%20do%0A%20%20def%20sum%28a%2Cb%29%0A%20%20%20%20a+b%0A%20%20end%0Aend',
    'function' => 'sum',
    'value'    => 35,
  }
)

describe 'function check' do
  it 'should pass' do
    expect(subject.parse.to_json).to eql(output)
  end
end
