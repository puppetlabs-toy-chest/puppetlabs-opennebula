# OpenNebula parameter class. This provides variables to the opennebula module.
# Not to be used directly.
#
# === OS Support
#
# * Debian
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
# [oned_conf_path]
#   Path to oned.conf
# [controller_user]
#   The user the oned daemon runs as.
# [controller_group]
#   The group the oned daemon runs as.
# [sinatra_package]
#   Package(s) for installing Ruby Sinatra.
# [oneadmin_home]
#   Location of oneadmin users home directory.
# [econe_conf_path]
#   Path to econe.conf.
# [curl_package]
#   Package(s) for curl.
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
      $oned_conf_path = "/etc/one/oned.conf"
      $controller_user = "oneadmin"
      $controller_group = "cloud"
      $sinatra_package = "libsinatra-ruby"
      $oneadmin_home = "/var/lib/one/"
      $econe_conf_path = "/etc/one/econe.conf"
      $curl_package = ["curl", "libcurl4-openssl-dev"]
    }
    default: {
      fail("Operating system ${operatingsystem} is not supported")
    }
  }

}
