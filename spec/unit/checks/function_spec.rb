require 'spec_helper'

output = '{"exitcode":0,"message":["passed"]}'

describe 'function check' do
  context 'passing an Array for args' do
    subject = Magicbox::Checks::Function.new(
      {
        'args'     => [10, 25],
        'code'     => 'Puppet%3A%3AFunctions.create_function%28%3Asum%29%20do%0A%20%20def%20sum%28a%2Cb%29%0A%20%20%20%20a+b%0A%20%20end%0Aend',
        'function' => 'sum',
        'value'    => 35,
      }
    )

    it 'should pass' do
      expect(subject.parse.to_json).to eql(output)
    end
  end
  context 'passing a String for args' do
    subject = Magicbox::Checks::Function.new(
      {
        'args'     => '%3C%25%3D%20%27test%20string%27%20%25%3E',
        'code'     => 'Puppet%3A%3AParser%3A%3AFunctions%3A%3Anewfunction%28%0A%20%20%3Amagic_template%2C%0A%20%20%3Atype%20%3D%3E%20%3Arvalue%0A%29%20do%20%7Cargs%7C%0A%20%20function_inline_template%28args%5B0%5D%29%0Aend',
        'function' => 'magic_template',
        'value'    => '%27test%20string%27',
      }
    )

    it 'should pass' do
      expect(subject.parse.to_json).to eql(output)
    end
  end
end
