# Install an OpenNebula controller.
#
# == Parameters
#
# [oneadmin_password]
#   *Mandatory* Main oneadmin password.
# [controller_package]
#   *Optional* Package(s) for installing the controller binaries.
# [controller_service]
#   *Optional* Service(s) for stopping and starting the controller process.
# [controller_conf_path]
#   *Optional* Path to oned.conf.
# [controller_user]
#   *Optional* User the oned daemon runs as.
# [controller_group]
#   *Optional* Group the oned daemon runs as.
# [oneadmin_home]
#   *Optional* Home directory of oneadmin user.
#
# == Variables
#
# N/A
#
# == Examples
#
#   class { 'opennebula::controller':
#     oneadmin_password => "gavilona",
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
class opennebula::controller (

  $oneadmin_password,
  $controller_package = $opennebula::params::controller_package,
  $controller_service = $opennebula::params::controller_service,
  $controller_conf_path = $opennebula::params::controller_conf_path,
  $controller_user = $opennebula::params::controller_user,
  $controller_group = $opennebula::params::controller_group,
  $oneadmin_home = $opennebula::params::oneadmin_home

  ) inherits opennebula::params {

  $oneadmin_authfile = "${oneadmin_home}/.one/one_auth"
  $oneadmin_sshkey = "${oneadmin_home}/.ssh/id_rsa"
  $oneadmin_ssh_config = "${oneadmin_home}/.ssh/config"

  Package[$controller_package] -> File[$oneadmin_authfile] -> 
    File[$oneadmin_sshkey] -> Service[$controller_service]

  package { $controller_package:
    ensure => installed,
  }

  file { $oneadmin_authfile:
    content => "oneadmin:${oneadmin_password}\n",
    owner => $controller_user,
    group => $controller_group,
    mode => "0640",
    require => Package[$controller_package],
  }
  file { $oneadmin_sshkey:
    content => template("${module_name}/controller_id_rsa"),
    owner => $controller_user,
    group => $controller_group,
    mode => "0600",
    require => Package[$controller_package],
  }
  file { $oneadmin_ssh_config:
    content => template("${module_name}/ssh_config"),
    owner => $controller_user,
    group => $controller_group,
    mode => "0644",
    require => Package[$controller_package],
  }
  file { $controller_conf_path:
    content => template("${module_name}/oned.conf"),
    owner => "root",
    group => "root",
    mode => "0644",
    require => Package[$controller_package],
  }

  service { $controller_service:
    hasstatus => false,
    pattern => "/usr/bin/oned",
    hasrestart => true,
    enable => true,
    ensure => running,
    require => Package[$controller_package],
    subscribe => File[$controller_conf_path],
  }

}
