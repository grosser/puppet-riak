require 'spec_helper'

describe 'riak' do
  let(:boxen_home) { '/opt/boxen' }
  let(:configdir)  { "#{boxen_home}/config/riak" }
  let(:version)    { '1.2.1-x86_64-boxen1' }
  let(:facts) do
    {
      :boxen_home      => '/opt/boxen',
      :boxen_user      => 'wfarr',
      :luser           => 'wfarr',
      :operatingsystem => 'Darwin',
    }
  end

  it do
    should include_class('homebrew')

    should contain_file("#{boxen_home}/config/riak").with_ensure('directory')
    should contain_file("#{boxen_home}/data/riak").with_ensure('directory')
    should contain_file("#{boxen_home}/log/riak").with_ensure('directory')

    should contain_file("#{configdir}/app.config").with_content(File.read("spec/fixtures/app.config"))
    should_not contain_file("#{configdir}/app.config").with_notify('Service[dev.riak]')

    should contain_file('/Library/LaunchDaemons/dev.riak.plist').with({
      :content => File.read('spec/fixtures/riak.plist'),
      :group   => 'wheel',
      :owner   => 'root'
    })
    should_not contain_file('/Library/LaunchDaemons/dev.riak.plist').with_notify('Service[dev.riak]')

    should contain_homebrew__formula('riak').
      with_before('Package[boxen/brews/riak]')

    should contain_package('boxen/brews/riak').
      with_ensure(version)

    #should_not contain_package('boxen/brews/riak').
      #with_notify('Service[dev.riak]')

    should contain_file('/opt/boxen/env.d/riak.sh').with({
      :content => File.read('spec/fixtures/riak.sh'),
      :require => 'File[/opt/boxen/env.d]'
    })

    should contain_file("/opt/boxen/homebrew/Cellar/riak/#{version}/libexec/etc/app.config").with({
      :ensure  => 'link',
      :force   => true,
      :target  => '/opt/boxen/config/riak/app.config',
      :require => [
        'Package[boxen/brews/riak]',
        'File[/opt/boxen/config/riak/app.config]'
      ]
    })
  end
end
