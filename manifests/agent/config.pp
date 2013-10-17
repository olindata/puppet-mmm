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
  Mysql_user {
    require => Package['mysql-server'],
  }

  Mysql_grant {
    table   => '*.*',
    require => Package['mysql-server'],
  }

  File {
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    require => Package[$mmm::params::agent_package],
  }

  mysql_user { $replication_user:
    name          => "${replication_user}@${localsubnet}",
    password_hash => mysql_password($replication_password),
  }

  mysql_grant { "${replication_user}@${localsubnet}":
    privileges => ['replication slave'],
    user       => "${replication_user}@${localsubnet}",
  }

  mysql_user { $agent_user:
    name          => "${agent_user}@${localsubnet}",
    password_hash => mysql_password($agent_password),
  }

  mysql_grant { "${agent_user}@${localsubnet}":
    privileges => ['replication client', 'super', 'process'],
    user       => "${replication_user}@${localsubnet}",
  }

  if ($monitor_user != $agent_user) {
    mysql_user { $monitor_user:
      name          => "${monitor_user}@${localsubnet}",
      password_hash => mysql_password($monitor_password),
    }

    mysql_grant { "${monitor_user}@${localsubnet}":
      privileges => ['replication client'],
      user       => "${replication_user}@${localsubnet}",
    }
  }

  # only create reader user if it is specified, on clusters without readers it won't be necessary
  if ($reader_user != '') {
    mysql_user { $reader_user:
      name          => "${reader_user}@${localsubnet}",
      password_hash => mysql_password($reader_pass),
    }

    mysql_grant { "${reader_user}@${localsubnet}":
      privileges => ['select'],
      user       => "${replication_user}@${localsubnet}",
    }
  }

  mysql_user { $writer_user:
    name          => "${writer_user}@${localsubnet}",
    password_hash => mysql_password($writer_pass),
  }

  mysql_grant { "${writer_user}@${localsubnet}":
    privileges => ['select', 'update', 'insert', 'delete', 'create', 'alter', 'drop'],
    user       => "${replication_user}@${localsubnet}",
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
      Package[$mmm::params::agent_package],
      File['/etc/mysql-mmm/mmm_agent.conf'],
      File['/etc/mysql-mmm/mmm_common.conf']
    ],
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }

}
