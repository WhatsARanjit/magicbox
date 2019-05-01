require 'spec_helper'

describe 'validate check' do
  context 'validating hcl to json conversion' do
    output  = '{"exitcode":0,"message":["{","  \"resource\": {","    \"mytype\": {","      \"myname\": {","        \"foo\": \"bar\"","      }","    }","  }","}"]}'
    subject = Magicbox::Checks::Validate.new(
      {
        'code' => 'resource%20%22mytype%22%20%22myname%22%20%7B%0A%20%20foo%20%3D%20%22bar%22%0A%7D',
        'lang' => 'json',
      }
    )
    it 'should pass' do
      expect(subject.parse.to_json).to eql(output)
    end
  end
  context 'validating json to hcl conversion' do
    output  = '{"exitcode":0,"message":["resource {", "  myresource {", "    test {", "      foo = "bar"", "      baz = true", "    }", "  }", "}"]}'
    subject = Magicbox::Checks::Validate.new(
      {
        'code' => '%7B%0A%20%20%22resource%22%3A%20%7B%0A%20%20%20%20%22myresource%22%3A%20%7B%0A%20%20%20%20%20%20%22test%22%3A%20%7B%0A%20%20%20%20%20%20%20%20%22foo%22%3A%20%22bar%22%2C%0A%20%20%20%20%20%20%20%20%22baz%22%3A%20true%0A%20%20%20%20%20%20%7D%0A%20%20%20%20%7D%0A%20%20%7D%0A%7D',
        'lang' => 'hcl',
      }
    )
    it 'should pass' do
      expect(subject.parse.to_json).to eql(output)
    end
  end
end
