require 'spec_helper'

output = '{"exitcode":0,"message":["passed"]}'

subject = Magicbox::Checks::Compile.new(
  {
    'code' => 'class magic_module { notice%28true%29 }',
    'item' => 'magic_module',
  }
)

describe 'compile check' do
  it 'should pass' do
    expect(subject.parse).to eql(output)
  end
end
