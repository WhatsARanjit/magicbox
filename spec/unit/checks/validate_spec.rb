require 'spec_helper'

describe 'validate check' do
  context 'validating puppet' do
    output  = '{"exitcode":0,"message":[]}'
    subject = Magicbox::Checks::Validate.new(
      {
        'code' => 'ranjit%20%7B%20%27test%27%3A%0A%20%20ensure%20%3D%3E%20present%2C%0A%7D',
        'lang' => 'puppet',
      }
    )
    it 'should pass' do
      expect(subject.parse.to_json).to eql(output)
    end
  end

  context 'validating ruby' do
    output  = '{"exitcode":0,"message":["Syntax OK"]}'
    subject = Magicbox::Checks::Validate.new(
      {
        'code' => 'Facter.add%28%27truth%27%29%20do%0A%20%20setcode%20do%0A%20%20%20%20true%0A%20%20end%0Aend',
        'lang' => 'ruby',
      }
    )
    it 'should pass' do
      expect(subject.parse.to_json).to eql(output)
    end
  end

  context 'validating yaml' do
    output  = '{"exitcode":0,"message":[]}'
    subject = Magicbox::Checks::Validate.new(
      {
        'code' => '---%0Aranjit%3A%20test',
        'lang' => 'yaml',
      }
    )
    it 'should pass' do
      expect(subject.parse.to_json).to eql(output)
    end
  end

  context 'validating json' do
    output  = '{"exitcode":0,"message":[]}'
    subject = Magicbox::Checks::Validate.new(
      {
        'code' => '%7B%0A%20%20%22ranjit%22%3A%20%22test%22%0A%7D',
        'lang' => 'json',
      }
    )
    it 'should pass' do
      expect(subject.parse.to_json).to eql(output)
    end
  end
end
