
define mmm::agent::config($localsubnet, $replication_user,
  $replication_password, $agent_user, $agent_password, $monitor_user,
  $monitor_password, $reader_user, $reader_pass, $writer_user, $writer_pass,
  $writer_virtual_ip, $reader_virtual_ips) {

  include mmm::params

  database_user{ $replication_user:
    name          => "${replication_user}@${localsubnet}",
    password_hash => mysql_password($replication_password),
    require       => Package['mysql-server']
  }
  database_grant{ "${replication_user}@${localsubnet}":
    privileges => ['repl_slave_priv'],
    require       => Package['mysql-server']
  }


  database_user{ $agent_user:
    name          => "${agent_user}@${localsubnet}",
    password_hash => mysql_password($agent_password),
    require       => Package['mysql-server']
  }
  database_grant{ "${agent_user}@${localsubnet}":
    privileges => ['repl_client_priv', 'super_priv', 'process_priv'],
    require       => Package['mysql-server']
  }

  if ($monitor_user != $agent_user) {
    database_user{ $monitor_user:
      name          => "${monitor_user}@${localsubnet}",
      password_hash => mysql_password($monitor_password),
      require       => Package['mysql-server']
    }
    database_grant{ "${monitor_user}@${localsubnet}":
      privileges => ['repl_client_priv'],
      require       => Package['mysql-server']
    }
  }

  # only create reader user if it is specified, on clusters without readers it won't be necessary
  if ($reader_user != '') {
    database_user{ $reader_user:
      name          => "${reader_user}@${localsubnet}",
      password_hash => mysql_password($reader_pass),
      require       => Package['mysql-server']
    }
    database_grant{ "${reader_user}@${localsubnet}":
      privileges => ['select_priv'],
      require       => Package['mysql-server']
    }
  }

  database_user{ $writer_user:
    name          => "${writer_user}@${localsubnet}",
    password_hash => mysql_password($writer_pass),
    require       => Package['mysql-server']
  }
  database_grant{ "${writer_user}@${localsubnet}":
    privileges => ['select_priv', 'update_priv', 'insert_priv', 'delete_priv', 'create_priv', 'alter_priv', 'drop_priv'],
    require       => Package['mysql-server']
  }

  file { '/etc/mysql-mmm/mmm_agent.conf':
    ensure  => present,
    mode    => 0600,
    owner   => 'root',
    group   => 'root',
    content => template('mmm/mmm_agent.conf.erb'),
    require => Package['mysql-mmm-agent'],
  }

  file { '/etc/init.d/mysql-mmm-agent':
    ensure  => present,
    mode    => 0755,
    owner   => 'root',
    group   => 'root',
    content => template('mmm/agent-init-d.erb'),
    require => Package['mysql-mmm-agent'],
  }

  service { 'mysql-mmm-agent':
    ensure         => running,
    subscribe      => [
      Package[mysql-mmm-agent],
      File['/etc/mysql-mmm/mmm_agent.conf'],
      File['/etc/mysql-mmm/mmm_common.conf']
    ],
    enable         => true,
    hasrestart     => true,
    hasstatus      => true,
    require        => [
      Package[mysql-mmm-agent],
      File['/etc/mysql-mmm/mmm_agent.conf'],
      File['/etc/mysql-mmm/mmm_common.conf']
    ]
  }

}
