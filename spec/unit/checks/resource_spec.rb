require 'spec_helper'

describe 'resource check' do
  context 'with type and title' do
    output  = %r({"exitcode":0,"message":\["file { '/etc/motd':)
    subject = Magicbox::Checks::Resource.new(
      {
        'code'  => 'puppet%20resource%20file%20/etc/motd',
        'type'  => 'file',
        'title' => '/etc/motd',
      }
    )

    it 'should pass' do
      expect(subject.parse.to_json).to match(output)
    end
  end

  context 'with munged output' do
    subject = Magicbox::Checks::Resource.new(
      {
        'code'  => 'puppet%20resource%20file%20/etc/motd',
        'type'  => 'file',
        'title' => '/etc/motd',
        'munge' => { 'ensure' => 'fake' },
      }
    )

    it 'should error with custom message' do
      expect(subject.parse.to_json).to match(/fake/)
    end
  end

  context 'with filtered output' do
    subject = Magicbox::Checks::Resource.new(
      {
        'code'   => 'puppet%20resource%20file%20/etc/motd',
        'type'   => 'file',
        'title'  => '/etc/motd',
        'filter' => ['ensure'],
      }
    )

    it 'should return only 1 attribute' do
      expect(subject.parse.to_json.scan(/=>/).count).to eql(1)
    end
  end
end
