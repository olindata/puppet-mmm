define mmm::monitor::config(
  $port,
  $cluster_name,
  $monitor_ip,
  $masters,
  $slaves,
  $monitor_user,
  $monitor_password
) {
  include mmm::params

  File {
    mode    => 0600,
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    require => Package['mysql-mmm-monitor'],
  }

  Service {
    enable     => true,
    ensure     => running,
    hasrestart => true,
    hasstatus  => true,
  }

  case $cluster_name {
    '': {
      file { '/etc/mysql-mmm/mmm_mon.conf':
        content => template('mmm/mmm_mon.conf.erb'),
      }
      file { '/etc/init.d/mysql-mmm-monitor':
        mode    => 0755,
        content => template('mmm/mon-init-d.erb'),
      }
      service { 'mysql-mmm-monitor':
        subscribe  => File[
          '/etc/mysql-mmm/mmm_mon.conf',
          '/etc/mysql-mmm/mmm_common.conf'
        ],
      }
    }
    default: {
      if ($mmm::params::multi_cluster_monitor) {
        $mon_dot_conf_name = "/etc/mysql-mmm/mmm_mon_${cluster_name}.conf"
        $mon_init_d_name   = "/etc/init.d/mysql-mmm-monitor-${cluster_name}"
        $service_name      = "mysql-mmm-monitor-${cluster_name}"

        # since mmm::monitor::config can be defined multipe times when there
        # are multiple clusters on one monitor, we need to check here to
        # make sure we don't double-define the normal common file to be
        # excluded
        if defined(File['/etc/mysql-mmm/mmm_mon.conf']) {
          notice('/etc/mysql-mmm/mmm_mon.conf already defined, skipping in module mmm:monitor::config')
        } else {
          file { '/etc/mysql-mmm/mmm_mon.conf':
            ensure  => absent,
          }
        }
        # since mmm::monitor::config can be defined multipe times when there
        # are multiple clusters on one monitor, we need to check here to
        # make sure we don't double-define the normal init.d file to be
        # excluded
          if defined(File['/etc/init.d/mysql-mmm-monitor']) {
          notice('/etc/init.d/mysql-mmm-monitor already defined, skipping in module mmm:monitor::config')
        } else {
          file { '/etc/init.d/mysql-mmm-monitor':
            ensure  => absent,
          }
        }

      } else {
        $mon_dot_conf_name = '/etc/mysql-mmm/mmm_mon.conf'
        $mon_init_d_name   = '/etc/init.d/mysql-mmm-monitor'
        $service_name      = 'mysql-mmm-monitor'
      }


      file { $mon_dot_conf_name:
        content => template('mmm/mmm_mon.conf.erb'),
      }

      file { $mon_init_d_name:
        mode    => 0755,
        content => template('mmm/mon-init-d.erb'),
      }

      service { $service_name:
        subscribe  => File[$mon_dot_conf_name],
      }
    }
  }
}
