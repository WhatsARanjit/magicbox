require 'spec_helper'

output = '{"exitcode":0,"message":["expected: true","actual: true"]}'

subject = Magicbox::Checks::Fact.new(
  {
    'code'  => 'Facter.add%28%27truth%27%29%20do%0A%20%20setcode%20do%0A%20%20%20%20true%0A%20%20end%0Aend',
    'fact'  => 'truth',
    'value' => true,
  }
)

describe 'fact check' do
  it 'should pass' do
    expect(subject.parse).to eql(output)
  end
end
