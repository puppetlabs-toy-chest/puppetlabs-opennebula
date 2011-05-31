# OpenNebula parameter class. Not to be used directly.
#
# == OS Support
#
# * Debian 7.0 (wheezy)
# * Ubuntu
#
# == Variables
#
# This is a list of variables that must be set for each operating system.
# 
# [node_package]
#   Package(s) for installing the node.
# [controller_package]
#   Package(s) for installing the controller binaries.
# [controller_service]
#   Service(s) for stopping and starting the controller process.
# [controller_conf_path]
#   Path to oned.conf
# [controller_user]
#   The user the oned daemon runs as.
# [controller_group]
#   The group the oned daemon runs as.
# [oneadmin_home]
#   Location of oneadmin users home directory.
#
# == Authors
#
# Ken Barber <ken@bob.sh>
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class opennebula::params {

  case $operatingsystem {
    'ubuntu', 'debian': {
      $node_package = "opennebula-node"
      $controller_package = "opennebula"
      $controller_service = "opennebula"
      $controller_conf_path = "/etc/one/oned.conf"
      $controller_user = "oneadmin"
      $controller_group = "cloud"
      $oneadmin_home = "/var/lib/one/"
    }
    default: {
      fail("Operating system ${operatingsystem} is not supported")
    }
  }

}
