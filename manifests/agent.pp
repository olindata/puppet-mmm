class mmm::agent(
  $node_type = '',
  $agent_enabled = $mmm::params::agent_enabled,
) inherits mmm::params {

  package { 'mysql-mmm-agent':
    ensure  => 'present',
    require => Package['mysql-server']
  }

  file { '/etc/mysql-mmm/mmm_agent.conf':
    ensure  => present,
    mode    => 0755,
    owner   => 'root',
    group   => 'root',
    content => template('mmm/mmm_agent.conf.erb'),
    require => Package['mysql-mmm-agent'],
    purge   => true,
  }
    
  file { '/etc/default/mysql-mmm-agent':
    ensure  => present,
    mode    => 0644,
    owner   => 'root',
    group   => 'root',
    content => template('mmm/agent-default.erb'),
    require => Package['mysql-mmm-agent'],
  }
  
}
