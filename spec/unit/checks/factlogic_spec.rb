require 'spec_helper'

output = '{"exitcode":0,"message":["passed"]}'

describe 'factlogic check' do
  subject = Magicbox::Checks::Factlogic.new(
    {
      'code'     => 'class magic_module { if%20%24kernel%20%3D%3D%20%27windows%27%20%7B%0A%20%20%20%20%24motd_file%20%3D%20%27C%3A%5Cmotd.txt%27%0A%7D%0Aelse%20%7B%0A%20%20%20%20%24motd_file%20%3D%20%27/etc/motd%27%0A%7D%0A%0Afile%20%7B%20%24motd_file%3A%0A%20%20content%20%3D%3E%20%27Hello%20world%27%2C%0A%7D%0A%20%20%20%20 }',
      'spec'     => 'logic',
      'facts_hash' => {
        'kernel' => {
          'linux' => {
            'type'  => 'file',
            'title' => '/etc/motd',
          },
          'windows' => {
            'type'  => 'file',
            'title' => 'C:\motd.txt',
          },
        },
      },
    }
  )

  it 'should pass' do
    expect(subject.parse.to_json).to eql(output)
  end
end
