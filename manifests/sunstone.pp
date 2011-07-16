# Setup the OpenNebula Sunstone interface.
#
# == Parameters
#
# [TODO]
#   *Optional* TODO
#
# == Variables
#
# N/A
#
# == Examples
#
# Basic example:
#
#   # You must always include the controller
#   class { 'opennebula::controller': oneadmin_password => "foo" }
#   class { 'opennebula::sunstone': }
#
# == Authors
#
# PuppetLabs <info@puppetlabs.com>
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class opennebula::sunstone (
  
  $one_xmlrpc = "http://localhost:2633/RPC2",
  $port = 4567,
  $server = $fqdn,
  $sinatra_package = $opennebula::params::sinatra_package,
  $curl_package = $opennebula::params::curl_package,
  $sunstone_package = $opennebula::params::sunstone_package,
  $sunstone_conf_path = $opennebula::params::sunstone_conf_path
  
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
    start => "/usr/bin/sunstone-server -H 0.0.0.0 -p 4568 start",
    stop => "/usr/bin/sunstone-server start",
    provider => "base",
    require => Package[$sunstone_package],
  }

}
