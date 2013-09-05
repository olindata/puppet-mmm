class mmm::monitor(
  $enabled = true
){
  include mmm::params
  include mmm::common

  validate_bool($enabled)

  File {
    owner   => 'root',
    group   => 'root',
  }
  
  package { 'mysql-mmm-monitor':
    ensure => installed
  }
  
  file { '/etc/mysql-mmm':
    ensure  => directory,
    mode    => 0755,
  }

  file { '/etc/default/mysql-mmm-monitor':
    ensure  => present,
    mode    => 0644,
    content => template('mmm/mon-default.erb'),
    require => Package['mysql-mmm-monitor'],
  }  
}
