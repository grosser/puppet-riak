# Internal: default values

class riak::params {
  case $::operatingsystem {
    Darwin: {
      include boxen::config

      $configdir  = "${boxen::config::configdir}/riak"
      $datadir    = "${boxen::config::datadir}/riak"
      $logdir     = "${boxen::config::logdir}/riak"
      $port       = 18098

      $executable = "${boxen::config::home}/homebrew/bin/riak"

      $version    = '1.2.1-x86_64-boxen1'
    }

    default: {
      fail('Unsupported operating system. See puppet-riak/manifests/params.pp')
    }
  }
}
