class mmm::agent {
  
  include mmm::common

  package { "mysql-mmm-agent":
    ensure => 'present'
  }
  
  file { "/etc/mysql-mmm":
    ensure => "directory",
      mode    => 0755,
      owner   => "root", 
      group   => "root",
    
  }
  file { "/etc/default/mysql-mmm-agent":
    ensure  => present,
    mode  => 0644,
    owner  => "root",
    group  => "root",
    content   => template("mmm/agent-default.erb"),
    require   => Package["mysql-mmm-agent"],
  }  

  
  include mariadb::server      
}