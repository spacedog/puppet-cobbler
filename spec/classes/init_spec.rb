require 'spec_helper'

describe 'cobbler' do
  let(:facts) {
    {
      :fqdn            => 'test.example.com',
      :hostname        => 'test',
      :ipaddress       => '192.168.0.1',
      :operatingsystem => 'CentOS',
      :osfamily        => 'RedHat'
    }
  }
  context 'with defaults for all parameters' do
    it { should contain_class('cobbler') }
    it { should contain_class('cobbler::install') }
    it { should contain_class('cobbler::config').that_requires('Class[cobbler::install]') }
    it { should contain_class('cobbler::service').that_subscribes_to('Class[cobbler::config]') }
  end

end
