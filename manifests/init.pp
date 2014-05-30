# Installs custom Riak from homebrew.
#
# Usage:
#
#     include riak
class riak (
  $configdir  = $riak::params::configdir,
  $datadir    = $riak::params::datadir,
  $executable = $riak::params::executable,
  $logdir     = $riak::params::logdir,
  $port       = $riak::params::port,
  $pb_port    = $riak::params::pb_port,
  $version    = $riak::params::version,
) inherits riak::params {
  include homebrew

  file { [
    $configdir,
    $datadir,
    $logdir
  ]:
    ensure => directory
  }

  file { "${configdir}/app.config":
    content => template('riak/app.config.erb'),
  #    notify  => Service['dev.riak']
  }

  file { '/Library/LaunchDaemons/dev.riak.plist':
    content => template('riak/dev.riak.plist.erb'),
    group   => 'wheel',
    owner   => 'root',
  #    notify  => Service['dev.riak']
  }

  homebrew::formula { 'riak':
    before => Package['boxen/brews/riak']
  }

  package { 'boxen/brews/riak':
    ensure => $version,
    notify => Service['dev.riak']
  }

  service { 'dev.riak':
    ensure  => 'stopped',
    require => Package['boxen/brews/riak']
  }

  service { 'com.boxen.riak': # replaced by dev.riak
    before => Service['dev.riak'],
    enable => false
  }

  file { "${boxen::config::envdir}/riak.sh":
    content => template('riak/env.sh.erb'),
    require => File[$boxen::config::envdir]
  }

  file { "${boxen::config::homebrewdir}/Cellar/riak/${version}/libexec/etc/app.config":
    ensure  => link,
    force   => true,
    target  => "${configdir}/app.config",
    require => [Package['boxen/brews/riak'],
      File["${configdir}/app.config"]]
  }
}
