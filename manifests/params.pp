# OpenNebula parameter class. This provides variables to the opennebula module.
#
# *Warning:* Not to be used directly in user content.
#
# === OS Support
#
# Currently we only resolve parameters for the following operatingsystems:
#
# * Debian
# * Ubuntu
#
# If your operatingsystem fact doesn't match this list, we fail.
#
# === Variables
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
# == Copyright
#
# Copyright 2011-2012 Puppetlabs Inc, unless otherwise noted.
#
class opennebula::params {

  case $operatingsystem {
    'ubuntu', 'debian': {
      # opennebula::controller params
      $controller_package = "opennebula"
      $controller_service = "opennebula"
      $controller_user = "oneadmin"
      $controller_group = "cloud"
      $oneadmin_home = "/var/lib/one/"

      # opennebula::oned_config params (called by opennebula::controler)
      $oned_conf_path = "/etc/one/oned.conf"

      $node_package = "opennebula-node"
      $sinatra_package = "libsinatra-ruby"
      $econe_conf_path = "/etc/one/econe.conf"
      $curl_package = ["curl", "libcurl4-openssl-dev"]
      $sunstone_package = "opennebula-sunstone"
      $sunstone_conf_path = "/tmp/foo"
    }
    default: {
      fail("Operating system ${operatingsystem} is not supported")
    }
  }

}
