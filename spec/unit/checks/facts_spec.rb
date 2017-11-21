require 'spec_helper'

output = '{"exitcode":0,"message":["Linux"]}'

subject = Magicbox::Checks::Facts.new(
  {
    'fact' => 'kernel',
  }
)

describe 'facts check' do
  it 'should pass' do
    expect(subject.parse.to_json).to eql(output)
  end
end
