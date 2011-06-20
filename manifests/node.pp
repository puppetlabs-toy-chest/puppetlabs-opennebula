# Install an OpenNebula node.
#
# == Parameters
#
# [controller]
#   *Mandatory* Hostname of controller.
# [node_package]
#   *Optional* Package(s) for installing the node.
# [oneadmin_home]
#   *Optional* Home directory of oneadmin user.
#
# == Variables
#
# N/A
#
# == Examples
#
#   class { 'opennebula::node':
#   }
#
# == Authors
#
# Ken Barber <ken@bob.sh>
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class opennebula::node (
  
  $controller,
  $node_package = $opennebula::params::node_package,
  $oneadmin_home = $opennebula::params::oneadmin_home
  
  ) inherits opennebula::params {

  # Install node package
  package { $node_package:
    ensure => installed,
  }
  
  # Install ssh keys from controller
  Ssh_authorized_key <<| title == "oneadmin_controller_${controller}" |>> {
    require => Package[$node_package],
  }
  
}