require 'spec_helper'

describe 'apply check' do
  context 'without an output check' do
    subject = Magicbox::Checks::Apply.new(
      {
        'code' => 'file%20%7B%20%27/etc/motd%27%3A%0A%20%20content%20%3D%3E%20%22Hello%20world%5Cn%22%2C%0A%7D',
      }
    )

    it 'should pass' do
      expect(subject.parse['exitcode']).to eql(0)
    end
  end
  context 'with an output check' do
    subject = Magicbox::Checks::Apply.new(
      {
        'code'  => 'file%20%7B%20%27/etc/motd%27%3A%0A%20%20content%20%3D%3E%20%22Hello%20world%5Cn%22%2C%0A%7D',
        'check' => 'File%5C%5B%5C/etc%5C/motd%5C%5D.*d41d8cd98f00b204e9800998ecf8427e',
      }
    )

    it 'should pass' do
      expect(subject.parse['exitcode']).to eql(0)
    end
  end
end
