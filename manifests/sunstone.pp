# Setup the OpenNebula Sunstone interface.
#
# == Parameters
#
# === General Parameters
#
# [*port*]
#   *Optional* Port for sunstone to listen on.
#
# === Advanced Tunables
#
# [*sunstone_package*]
#   *Optional* The package to use for installing sunstone.
#
# == Examples
#
# Basic example:
#
#     # You must always include the controller
#     class { 'opennebula::controller': oneadmin_password => "foo" }
#     class { 'opennebula::sunstone': }
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class opennebula::sunstone (
  
  $port = 4568,
  $sunstone_package = $opennebula::params::sunstone_package
  
  ) inherits opennebula::params {
    
  # Currently we require parts of opennebula::controller  
  require(opennebula::controller)

  ############
  # Packages #
  ############
  package { $sunstone_package:
    ensure => installed,
  }

  ############
  # Services #
  ############
  service { "sunstone":
    ensure => running,
    start => "/usr/bin/sunstone-server -H 0.0.0.0 -p ${port} start",
    stop => "/usr/bin/sunstone-server start",
    provider => "base",
    require => Package[$sunstone_package],
  }

}
