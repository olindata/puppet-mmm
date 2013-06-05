class mmm(  
  $clustername = '',
  $node_type = '',
) {

  case $node_type {
    'monitor': { 
      include mmm::monitor
      mmm::monitor::config { $clustername:
      }
    }
    'writer', 'reader': {
      class { 'mmm::agent':
        node_type => $node_type,
      }      
    }
    default: {
      fail("invalid node_type for class mmm: ${node_type} in module ${module_name} on ${::hostname}")
    }
  }

  mmm::common::config { $clustername:  
  }
  
  file { '/etc/mysql-mmm':
    ensure  => 'directory',
    mode    => 0755,
    owner   => 'root',
    group   => 'root',
    require => Package['mysql-mmm-common'],
    purge   => true,
  }

  package { 'mysql-mmm-common':
    ensure => 'present'
  }

}