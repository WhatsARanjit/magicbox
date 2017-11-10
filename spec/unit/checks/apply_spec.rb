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
        'code'  => 'notify%20%7B%20%27hello%20world%27%3A%20%7D',
        'check' => 'changed%20to%20%27hello%20world%27',
      }
    )

    it 'should pass' do
      expect(subject.parse['exitcode']).to eql(0)
    end
  end
  context 'with a friendly error message' do
    subject = Magicbox::Checks::Apply.new(
      {
        'code'  => 'notify%20%7B%20%27hello%20world%27%3A%20%7D',
        'check' => 'changed%20to%20%27byebye%20world%27',
        'error' => 'This is a mistake',
      }
    )

    it 'should error with custom message' do
      expect(subject.parse['message'].first).to eql('This is a mistake')
    end
  end
end
