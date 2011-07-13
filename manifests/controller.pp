# Install and configure an OpenNebula controller.
#
# This installs the controller components for OpenNebula - the oned server. It
# also configures components at creation time if required: clusters, networks,
# hosts, vms, images and users.
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
# [clusters]
#   *Optional* A list of clusters to create. This list gets passed to the resource onecluster.
# [cluster_purge]
#   *Optional* Purge clusters that aren't explicitly defined by Puppet.
# [hosts]
#   *Optional* A list of onehost hashes to manage via OpenNebula. This gets passed to the resource onehost.
# [host_purge]
#   *Optional* Purge hosts that aren't explicitly defined by Puppet.
# [networks]
#   *Optional* A list of onevnet hashes to manage via OpenNebula. This gets passed to the resource onevnet.
# [network_purge]
#   *Optional* Purge networks that aren't explicitly defined by Puppet.
# [vms]
#   *Optional* A list of onevm hashes to manage via OpenNebula. This gets passed to the resource onevm.
# [vm_purge]
#   *Optional* Purge vms that aren't explicitly defined by Puppet.
# [images]
#   *Optional* A list of oneimage hash to manage via OpenNebula. This gets passed to the resource oneimage.
# [image_purge]
#   *Optional* Purge images that aren't explicitly defined by Puppet.
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
# Create clusters and hosts at class time:
#
#   class { 'opennebula::controller':
#     oneadmin_password => "gavilona",
#     hosts => {
#       "node1" => {
#         "tm_mad" => "tm_ssh",
#         "im_mad" => "im_kvm",
#         "vm_mad" => "vmm_kvm",
#       }
#     },
#     clusters => [
#       "ibm_blades",
#     ],
#     networks => {
#       "internal" => {
#         bridge => "virbr0",
#         type => "fixed",
#         public => true,
#         leases => ["192.168.128.2","192.168.128.3"],
#       }
#     },
#     vms => {
#       "box1" => {
#         memory => "256",
#         cpu => 1,
#         vcpu => 1,
#         os_arch => "x86_64",
#         disks => [
#           { type => "disk", source => "/tmp/diskimage", size => 8000, target => "hda", },
#           { type => "cdrom", source => "/tmp/installos", },
#         ],
#         graphics_type => "vnc",
#         graphics_listen => "0.0.0.0",
#       }
#     }
#     images => {
#       "debian-wheezy-64" => {
#         description => "Debian Wheezy 64 bit image",
#         path => "/srv/images/debian-wheezy-64.img",
#         type => "os",
#       }
#     }
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
  $oned_config = undef,
  $clusters = undef,
  $cluster_purge = false,
  $hosts = undef,
  $host_purge = false,
  $networks = undef,
  $network_purge = false,
  $vms = undef,
  $vm_purge = false,
  $images = undef,
  $image_purge = false

  ) inherits opennebula::params {

  # Work out other information
  $oneadmin_authfile = "${oneadmin_home}/.one/one_auth"
  $oneadmin_authfile_root = "/root/.one/one_auth"
  $oneadmin_ssh_config = "${oneadmin_home}/.ssh/config"

  Package[$controller_package] -> File[$oneadmin_authfile] -> 
    Service[$controller_service]

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
  file { "/root/.one":
    ensure => directory,
  }
  file { $oneadmin_authfile_root:
    content => "oneadmin:${oneadmin_password}\n",
    owner => "root",
    group => "root",
    mode => "0640",
    require => Package[$controller_package],
  }
 
  ########################
  # Setup SSH trust keys #
  ########################
  
  # Export key to all nodes
  @@ssh_authorized_key { "oneadmin_controller_${fqdn}":
    ensure => present,
    key => $::oneadmin_pubkey_rsa,
    name => "oneadmin_controller_${fqdn}",
    user => $controller_user,
    type => "ssh-rsa",
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

  ############
  # clusters #
  ############
  if($cluster_purge == true) {
    resources { "onecluster":
      purge => true,
    }
  }
  # default cluster should always exist
  onecluster { "default":
    ensure => present,
  }
  onecluster { $clusters: 
    ensure => present,
  }
  
  #########
  # Hosts #
  #########
  if($host_purge == true) {
    resources { "onehost":
      purge => true,
    }
  }
  if($hosts) {
    create_resources("onehost", $hosts)
  }
  
  ############
  # Networks #
  ############
  if($network_purge == true) {
    resources { "onevnet":
      purge => true,
    }
  }
  if($networks) {
    create_resources("onevnet", $networks)
  }
  
  #######
  # VMs #
  #######
  if($vm_purge == true) {
    resources { "onevm":
      purge => true,
    }
  }
  if($vms) {
    create_resources("onevm", $vms)
  }
  
  ##########
  # Images #
  ##########
  if($image_purge == true) {
    resources { "oneimage":
      purge => true,
    }
  }
  if($images) { 
    create_resources("oneimage", $images)
  }

  #############################
  # Contextualization scripts #
  #############################
  file { "/var/lib/one/context":
    ensure => directory,
    purge => true,
    recurse => true,
  }
  file { "/var/lib/one/context/init.sh":
    owner => "root",
    group => "root",
    mode => "0755",
    content => template("${module_name}/context/init.sh"),
  }

  ################
  # Hook Scripts #
  ################
  file { "/usr/share/one/hooks/puppet":
    ensure => directory,
    mode => "0755",
    owner => "root",
    group => "root",
    source => "puppet:///modules/${module_name}/hookscripts/",
    recurse => true,
    purge => true,
    require => Package[$controller_package],
  }
}
