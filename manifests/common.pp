define mmm::common {



  if ($clustername <> '') {
    $mmm_common_config_file = "/etc/mysql-mmm/mmm_common_${clustername}.conf"
  } else {
    $mmm_common_config_file = "/etc/mysql-mmm/mmm_common.conf"
  }
  
  concat { $mmm_common_config_file:
    path => $mmm_common_config_file,
    tag  => 'mmm_agent_conf'
  }
  
  concat::fragment { 'mmm_common.conf_common':
    target => $mmm_common_config_file,
    content => template('mmm/mmm_common.conf_common.erb'),
    order => 01
  }
  
  concat::fragment { 'mmm_common.conf_master':
    target => $mmm_common_config_file,
    content => template('mmm/mmm_common.conf_master.erb'),
    order => 02
  }
  
  concat::fragment { 'mmm_common.conf_slave':
    target => $mmm_common_config_file,
    content => template('mmm/mmm_common.conf_slave.erb'),
    order => 03
  }

}