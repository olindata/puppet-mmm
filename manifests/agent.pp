class mmm::agent(
  $enabled = true
) {
  include mmm::params
  include mmm::common

  validate_bool($enabled)

  package { $mmm::params::agent_package:
    ensure  => 'present',
    require => Package['mysql-server']
  }

  File {
    owner   => 'root',
    group   => 'root',
    require => Package['mysql-mmm-agent'],
  }

  file { '/etc/mysql-mmm':
    ensure  => directory,
    mode    => 0755,
    purge   => true,
  }

  file { '/etc/default/mysql-mmm-agent':
    ensure  => present,
    mode    => 0644,
    content => template('mmm/agent-default.erb'),
  }
}
