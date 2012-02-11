# Setup the OpenNebula econe server EC2 interface.
#
# This interface is Sinatra based. Currently it uses Webrick as a web server
# however it is recommended we improve this to use Apache + Passenger.
#
# == Parameters
#
# [one_xmlrpc]
#   *Optional* URL where your oned xmlrpc server is located.
# [port]
#   *Optional* Port to listen on.
# [server]
#   *Optional* Server where econe will run.
# [sinatra_package]
#   *Optional* Package(s) for installing Ruby Sinatra.
# [econe_conf_path]
#   *Optional* Path to econe.conf.
# [curl_package]
#   *Optional* Package(s) for installing curl.
#
# == Examples
#
# Basic example:
#
#     # You must always include the controller
#     class { 'opennebula::controller': oneadmin_password => "foo" }
#     class { 'opennebula::econe': 
#       one_server => "one.mydomain.com",
#     }
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class opennebula::econe (
  
  $one_xmlrpc = "http://localhost:2633/RPC2",
  $port = 4567,
  $server = $fqdn,
  $sinatra_package = $opennebula::params::sinatra_package,
  $econe_conf_path = $opennebula::params::econe_conf_path,
  $curl_package = $opennebula::params::curl_package
  
  ) inherits opennebula::params {
    
  # Currently we require parts of opennebula::controller  
  require(opennebula::controller)

  ########
  # Gems #
  ########
  package { "amazon-ec2":
    ensure => "0.5.5",
    provider => "gem",
  }
  package { ["curb", "uuid"]:
    ensure => installed,
    provider => "gem",
  }

  ############
  # Packages #
  ############
  package { $curl_package:
    ensure => installed,
    before => Package["curb"],
  }

  package { $sinatra_package:
    ensure => installed,
  }

  #################
  # Configuration #
  #################
  file { $econe_conf_path:
    owner => "root",
    group => "root",
    mode => "0644",
    content => template("opennebula/econe.conf"),
  }

}
