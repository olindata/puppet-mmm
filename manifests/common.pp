class mmm::common {
  include mmm::params

  package { $mmm::params::common_package:
    ensure => 'present'
  }
}
