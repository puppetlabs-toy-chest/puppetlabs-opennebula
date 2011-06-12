# Configure oned.conf.
#
# This class is designed to be used to configure oned.conf. 
#
# == Parameters
#
# [manager_time]
#   *Optional* 
# [host_monitoring_interval]
#   *Optional* 
# [vm_polling_interval]
#   *Optional* 
# [vm_dir]
#   *Optional* 
# [scripts_remote_dir]
#   *Optional* 
# [port]
#   *Optional* 
# [db_backend]
#   *Optional* 
# [db_server]
#   *Optional* 
# [db_user]
#   *Optional* 
# [db_name]
#   *Optional* 
# [db_port]
#   *Optional* 
# [vnc_base_port]
#   *Optional* 
# [debug_level]
#   *Optional* 
# [network_size]
#   *Optional* 
# [mac_prefix]
#   *Optional* 
# [image_repository_path]
#   *Optional* 
# [default_image_path]
#   *Optional* 
# [default_device_prefix]
#   *Optional* 
# [oned_conf_path]
#   *Optional* 
#
# == Variables
#
# N/A
#
# == Examples
#
# Basic example:
#
#     class { "opennebula::oned_conf":
#       port => 2633,
#     }
#
# == Authors
#
# Ken Barber <ken@bob.sh>
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class opennebula::oned_conf (
  
  $manager_timer = 15,
  $host_monitoring_interval = 600,
  $vm_polling_interval = 600,
  $vm_dir = "/var/lib/one/",
  $scripts_remote_dir = "/var/tmp/one",
  $port = 2633,
  $db_backend = "sqlite",
  $db_server = undef,
  $db_user = undef,
  $db_passwd = undef,
  $db_name = undef,
  $db_port = undef,
  $vnc_base_port = 5900,
  $debug_level = 3,
  $network_size = 254,
  $mac_prefix = "02:00",
  $image_repository_path = "/var/lib/one/images/",
  $default_image_type = "OS",
  $default_device_prefix = "hd",
  $oned_conf_path = $opennebula::params::oned_conf_path
  
  ) inherits opennebula::params {
    
  #################
  # Configuration #
  #################
  file { $oned_conf_path:
    content => template("${module_name}/oned.conf"),
    owner => "root",
    group => "root",
    mode => "0644",
    require => Package[$controller_package],
  }
}
