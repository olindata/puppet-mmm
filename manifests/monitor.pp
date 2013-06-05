class mmm::monitor inherits mmm::params {
   
  package { 'mysql-mmm-monitor':
    ensure => installed
  }
  
  file { '/etc/default/mysql-mmm-monitor':
    ensure  => present,
    mode    => 0644,
    owner   => 'root',
    group   => 'root',
    content => template('mmm/mon-default.erb'),
    require => Package['mysql-mmm-monitor'],
  }  

}