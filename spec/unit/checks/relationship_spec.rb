require 'spec_helper'

output = '{"exitcode":0,"message":["passed"]}'

describe 'relationship check' do
  subject = Magicbox::Checks::Relationship.new(
    {
      'code'          => 'class magic_module { package%20%7B%20%27puppet%27%3A%0A%20%20ensure%20%3D%3E%20installed%2C%0A%20%20before%20%3D%3E%20File%5B%27/etc/puppetlabs/puppet/puppet.conf%27%5D%2C%0A%7D%0Afile%20%7B%20%27/etc/puppetlabs/puppet/puppet.conf%27%3A%0A%20%20ensure%20%20%3D%3E%20file%2C%0A%20%20content%20%3D%3E%20%22%5Bmain%5D%5Cnserver%20%3D%20master.domain.com%22%2C%0A%20%20notify%20%20%3D%3E%20Service%5B%27puppet%27%5D%2C%0A%7D%0Aservice%20%7B%20%27puppet%27%3A%0A%20%20ensure%20%3D%3E%20running%2C%0A%7D }',
      'spec'          => 'relationship',
      'relationships' => {
        'File[/etc/puppetlabs/puppet/puppet.conf]' => {
          'require' => 'Package[puppet]',
        },
        'Service[puppet]' => {
          'subscribe' => 'File[/etc/puppetlabs/puppet/puppet.conf]',
        },
      },
    }
  )

  it 'should pass' do
    expect(subject.parse.to_json).to eql(output)
  end
end
