# Install an OpenNebula controller.
#
# This installs the controller components for OpenNebula - the oned server.
#
# == Parameters
#
# [oneadmin_password]
#   *Mandatory* Main oneadmin password.
# [controller_package]
#   *Optional* Package(s) for installing the controller binaries.
# [controller_service]
#   *Optional* Service(s) for stopping and starting the controller process.
# [oned_conf_path]
#   *Optional* Path to oned.conf.
# [controller_user]
#   *Optional* User the oned daemon runs as.
# [controller_group]
#   *Optional* Group the oned daemon runs as.
# [oneadmin_home]
#   *Optional* Home directory of oneadmin user.
# [oned_config]
#   *Optional* A hash for configuring oned.conf. This gets passed to the class opennebula::oned_conf.
#
# == Variables
#
# N/A
#
# == Examples
#
# Basic configuration:
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
  $oned_conf_path = $opennebula::params::oned_conf_path,
  $controller_user = $opennebula::params::controller_user,
  $controller_group = $opennebula::params::controller_group,
  $oneadmin_home = $opennebula::params::oneadmin_home,
  $oned_config = undef

  ) inherits opennebula::params {

  # Work out other information
  $oneadmin_authfile = "${oneadmin_home}/.one/one_auth"
  $oneadmin_sshkey = "${oneadmin_home}/.ssh/id_rsa"
  $oneadmin_ssh_config = "${oneadmin_home}/.ssh/config"

  Package[$controller_package] -> File[$oneadmin_authfile] -> 
    File[$oneadmin_sshkey] -> Service[$controller_service]

  package { $controller_package:
    ensure => installed,
  }

  # Authentication file
  file { $oneadmin_authfile:
    content => "oneadmin:${oneadmin_password}\n",
    owner => $controller_user,
    group => $controller_group,
    mode => "0640",
    require => Package[$controller_package],
  }
  
  ########################
  # Setup SSH trust keys #
  ########################
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
  
  ###############
  # Oned Config #
  ###############
  $config_hash = { 
    "opennebula::oned_conf" => $oned_config,   
  }
  create_resources("class", $config_hash)
  
  ################
  # Oned Service #
  ################
  service { $controller_service:
    hasstatus => false,
    pattern => "/usr/bin/oned",
    hasrestart => true,
    enable => true,
    ensure => running,
    require => Package[$controller_package],
    subscribe => Class["opennebula::oned_conf"],
  }

}
