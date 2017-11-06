require 'spec_helper'

describe 'webserver' do
  describe 'sanitize method' do
    it 'process a String' do
      expect(Magicbox::Webserver.sanitize('hello_world')).to eql('hello_world')
    end
    it 'process a String with a URL-encoding' do
      expect(Magicbox::Webserver.sanitize('class%20foo%20%7B%7D')).to eql('class foo {}')
    end
    it 'process a String with a +' do
      expect(Magicbox::Webserver.sanitize('hello%20world')).to eql('hello world')
    end
    it 'process an Array' do
      expect(Magicbox::Webserver.sanitize([1, 2])).to eql([1, 2])
    end
    it 'process a Boolean' do
      expect(Magicbox::Webserver.sanitize(true)).to eql(true)
    end
    it 'process a nil' do
      expect(Magicbox::Webserver.sanitize(nil)).to eql(nil)
    end
  end
end
