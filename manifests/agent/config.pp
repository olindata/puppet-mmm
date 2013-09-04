define mmm::agent::config(
  $localsubnet,
  $replication_user,
  $replication_password,
  $agent_user,
  $agent_password,
  $monitor_user,
  $monitor_password,
  $reader_user,
  $reader_pass,
  $writer_user,
  $writer_pass,
  $writer_virtual_ip,
  $reader_virtual_ips
) {
  include mmm::params

  # resource defaults
  Database_user {
    require => Package['mysql-server'],
  }

  Database_grant {
    require => Package['mysql-server'],
  }

  File {
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    require => Package['mysql-mmm-agent'],
  }

  database_user { $replication_user:
    name          => "${replication_user}@${localsubnet}",
    password_hash => mysql_password($replication_password),
  }

  database_grant { "${replication_user}@${localsubnet}":
    privileges => ['repl_slave_priv'],
  }

  database_user { $agent_user:
    name          => "${agent_user}@${localsubnet}",
    password_hash => mysql_password($agent_password),
  }

  database_grant { "${agent_user}@${localsubnet}":
    privileges => ['repl_client_priv', 'super_priv', 'process_priv'],
  }

  if ($monitor_user != $agent_user) {
    database_user { $monitor_user:
      name          => "${monitor_user}@${localsubnet}",
      password_hash => mysql_password($monitor_password),
    }

    database_grant { "${monitor_user}@${localsubnet}":
      privileges => ['repl_client_priv'],
    }
  }

  # only create reader user if it is specified, on clusters without readers it won't be necessary
  if ($reader_user != '') {
    database_user { $reader_user:
      name          => "${reader_user}@${localsubnet}",
      password_hash => mysql_password($reader_pass),
    }

    database_grant { "${reader_user}@${localsubnet}":
      privileges => ['select_priv'],
    }
  }

  database_user { $writer_user:
    name          => "${writer_user}@${localsubnet}",
    password_hash => mysql_password($writer_pass),
  }

  database_grant { "${writer_user}@${localsubnet}":
    privileges => ['select_priv', 'update_priv', 'insert_priv', 'delete_priv', 'create_priv', 'alter_priv', 'drop_priv'],
  }

  file { '/etc/mysql-mmm/mmm_agent.conf':
    mode    => 0600,
    content => template('mmm/mmm_agent.conf.erb'),
  }

  file { '/etc/init.d/mysql-mmm-agent':
    mode    => 0755,
    content => template('mmm/agent-init-d.erb'),
  }

  service { 'mysql-mmm-agent':
    ensure     => running,
    subscribe  => [
      Package['mysql-mmm-agent'],
      File['/etc/mysql-mmm/mmm_agent.conf'],
      File['/etc/mysql-mmm/mmm_common.conf']
    ],
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }

}
