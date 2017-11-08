require 'spec_helper'

output = %r({"exitcode":0,"message":\["file { '/etc/motd':)

subject = Magicbox::Checks::Resource.new(
  {
    'code'  => 'puppet%20resource%20file%20/etc/motd',
    'type'  => 'file',
    'title' => '/etc/motd',
  }
)

describe 'resource check' do
  it 'should pass' do
    expect(subject.parse.to_json).to match(output)
  end
end
