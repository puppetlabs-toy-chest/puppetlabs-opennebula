# Setup the OpenNebula EC2 interface.
#
# == Parameters
#
# N/A
#
# == Variables
#
# N/A
#
# == Examples
#
#   # You must always include the controller
#   class { 'opennebula::controller': oneadmin_password => "foo" }
#   class { 'opennebula::econe': }
#
# == Authors
#
# Ken Barber <ken@bob.sh>
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class opennebula::econe (
  $one_server = "localhost"
  ) inherits opennebula::params {
  require opennebula::controller

  package { "amazon-ec2":
    ensure => "0.5.5",
    provider => "gem",
  }

  package { ["curl", "libcurl4-openssl-dev"]:
    ensure => installed,
    before => Package["curb"],
  }

  package { "curb":
    ensure => installed,
    provider => "gem",
  }

  package { "libsinatra-ruby":
    ensure => installed,
  }

  package { "uuid":
    ensure => installed,
    provider => "gem",
  }

  file { "/etc/one/econe.conf":
    owner => "root",
    group => "root",
    mode => "0644",
    content => template("opennebula/econe.conf"),
  }

}
