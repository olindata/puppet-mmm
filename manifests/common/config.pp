define mmm::common::config($replication_user, $replication_password, $agent_user, 
  $agent_password, $cluster_interface, $cluster_name, $master_names, $master_ips, 
  $slave_ips, $masters, $slaves, $readers, $writer_virtual_ip, $reader_virtual_ips) {
  
  case $cluster_name {
    '': {
      file { "/etc/mysql-mmm/mmm_common.conf":
        ensure  => present,
        mode  => 0600,
        owner  => "root",
        group  => "root",
        content   => template("mmm/mmm_common.conf.erb"),
        require   => Package["mysql-mmm-common"],
      }
    }
    default: {
      
      # since mmm::common::config can be defined multipe times when there 
      # are multiple clusters on one monitor, we need to check here to 
      # make sure we don't double-define the normal common file to be 
      # excluded
        if defined(File["/etc/mysql-mmm/mmm_common.conf"]) {
        notice("/etc/mysql-mmm/mmm_common.conf already defined, skipping in module mmm:common::config")
      } else {
        file { "/etc/mysql-mmm/mmm_common.conf":
          ensure  => absent,
        }
      }

      file { "/etc/mysql-mmm/mmm_common_${cluster_name}.conf":
        ensure  => present,
        mode  => 0600,
        owner  => "root",
        group  => "root",
        content   => template("mmm/mmm_common.conf.erb"),
        require   => Package["mysql-mmm-common"],
      }
    }
  }
  
}