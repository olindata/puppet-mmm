define mmm::agent::config($localsubnet, $replication_user, 
  $replication_password, $agent_user, $agent_password, $monitor_user, 
  $monitor_password, $reader_user, $reader_pass, $writer_user, $writer_pass) {
  
  # GRANT REPLICATION CLIENT                 ON *.* TO 'mmm_monitor'@'192.168.%' IDENTIFIED BY 'monitor_password';
  # GRANT SUPER, REPLICATION CLIENT, PROCESS ON *.* TO 'mmm_agent'@'192.168.%'   IDENTIFIED BY 'agent_password';
  # GRANT REPLICATION SLAVE                  ON *.* TO 'replication'@'192.168.%' IDENTIFIED BY 'replication_password';    
    
  mariadb::user{ $replication_user:
        username        => $replication_user,
        pw              => $replication_password,
        dbname          => "*",
        grants          => "REPLICATION SLAVE",
        host_to_grant   => $localsubnet, 
        dbhost          => 'localhost', 
        withgrants      => false,
    }
    
  mariadb::user{ $agent_user:
        username        => $agent_user,
        pw              => $agent_password,
        dbname          => "*",
        grants          => "SUPER, REPLICATION CLIENT, PROCESS",
        host_to_grant   => $localsubnet, 
        dbhost          => 'localhost', 
        withgrants      => false,
    }

  mariadb::user{ $monitor_user:
        username        => $monitor_user,
        pw              => $monitor_password,
        dbname          => "*",
        grants          => "REPLICATION CLIENT",
        host_to_grant   => $localsubnet, 
        dbhost          => 'localhost', 
        withgrants      => false,
    }
  mariadb::user{ 'debian-sys-maint':
        username        => 'debian-sys-maint',
        pw              => $mariadb::params::debian_sys_maint_pass,
        dbname          => "*",
        grants          => "ALL PRIVILEGES",
        host_to_grant   => 'localhost', 
        dbhost          => 'localhost', 
        withgrants      => true
    }

  mariadb::user{ $reader_user:
        username        => $reader_user,
        pw              => $reader_pass,
        dbname          => "*",
        grants          => "SELECT",
        host_to_grant   => $localsubnet, 
        dbhost          => 'localhost', 
        withgrants      => false
    }
  mariadb::user{ $writer_user:
        username        => $writer_user,
        pw              => $writer_pass,
        dbname          => "*",
        grants          => "SELECT, UPDATE, INSERT, DELETE",
        host_to_grant   => $localsubnet, 
        dbhost          => 'localhost', 
        withgrants      => false
    }

  file { "/etc/mysql-mmm/mmm_agent.conf":
    ensure  => present,
    mode  => 0600,
    owner  => "root",
    group  => "root",
    content   => template("mmm/mmm_agent.conf.erb"),
    require   => Package["mysql-mmm-agent"],
  }
  file { "/etc/init.d/mysql-mmm-agent":
    ensure  => present,
    mode  => 0755,
    owner  => "root",
    group  => "root",
    content   => template("mmm/agent-init-d.erb"),
    require   => Package["mysql-mmm-agent"],
  }
  service { 'mysql-mmm-agent':
    subscribe      => Package[mysql-mmm-agent],
    enable         => true,
    ensure         => running,
    hasrestart     => true,
    hasstatus      => true 
  }
  
}
