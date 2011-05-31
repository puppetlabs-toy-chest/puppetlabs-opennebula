# Install an OpenNebula node.
#
# == Parameters
#
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
  $node_package = $node_package,
  $oneadmin_home = $oneadmin_home
  ) inherits opennebula::params {

  $oneadmin_sshkey_pub = "${oneadmin_home}/.ssh/id_rsa.pub"
  $oneadmin_authorized_keys = "${oneadmin_home}/.ssh/authorized_keys"

  package { $node_package:
    ensure => installed,
  }
  file { $oneadmin_sshkey_pub:
    content => template("${module_name}/controller_id_rsa.pub"),
    owner => "oneadmin",
    group => "cloud",
    mode => "0644",
    require => Package[$node_package],
  }
  file { $oneadmin_authorized_keys:
    content => template("${module_name}/controller_id_rsa.pub"),
    owner => "oneadmin",
    group => "cloud",
    mode => "0644",
    require => Package[$node_package],
  }

}
