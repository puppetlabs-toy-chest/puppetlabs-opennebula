# Install and configure an OpenNebula controller.
#
# This installs the controller components for OpenNebula - the oned server. It
# also configures components at creation time if required: clusters, networks,
# hosts, vms, images and users.
#
# == Parameters
#
# === Primary Configuration
#
# These elements are the one an average implementor should care the most about.
#
# [oneadmin_password]
#   *Mandatory* Main oneadmin password in cleartext. This absolutely must be set as we believe its insecure to define a default here.
#
# [oned_config]
#   *Optional* A hash for configuring oned.conf. This gets passed to the class opennebula::oned_conf. Defaults to undef.
#
# === Resources Creation
#
# These parameters are specifically for creating resources during creation of
# the class. This is often used by an ENC system as resources cannot be defined
# directly by an ENC.
#
# Of course, you can always manage these resources independantly. See the
# the resource documentation for this module for details.
#
# [clusters]
#   *Optional* A list of clusters to create. This list gets passed to the resource onecluster.
# [cluster_purge]
#   *Optional* Purge onecluster resources that aren't explicitly defined by Puppet.
# [hosts]
#   *Optional* Takes a hash of resource names and parameters to create multiple onehost resources. Defaults to undef.
# [host_purge]
#   *Optional* Purge onehost resources that aren't explicitly defined by Puppet.
# [networks]
#   *Optional* A list of onevnet hashes to manage via OpenNebula. This gets passed to the resource onevnet.
# [network_purge]
#   *Optional* Purge onevnet resources that aren't explicitly defined by Puppet.
# [vms]
#   *Optional* A list of onevm hashes to manage via OpenNebula. This gets passed to the resource onevm.
# [vm_purge]
#   *Optional* Purge onevm resources that aren't explicitly defined by Puppet.
# [images]
#   *Optional* A list of oneimage hash to manage via OpenNebula. This gets passed to the resource oneimage.
# [image_purge]
#   *Optional* Purge images that aren't explicitly defined by Puppet.
#
# === Advanced Tuning Parameters
#
# Ordinary these are best left alone, as the OS detection should handle this.
#
# However, these can be useful to override the assumptions made by this modules
# authors and perhaps support unanticipated scenarios.
#
# [controller_package]
#   *Optional* Package(s) for installing the controller binaries.
# [controller_service]
#   *Optional* Service(s) for stopping and starting the controller process.
# [controller_user]
#   *Optional* User the oned daemon runs as.
# [controller_group]
#   *Optional* Group the oned daemon runs as.
# [oneadmin_home]
#   *Optional* Home directory of oneadmin user.
#
# == Examples
#
# Basic configuration:
#
#     class { 'opennebula::controller':
#       oneadmin_password => "gavilona",
#     }
#
# Create clusters and hosts at class time:
#
#   class { 'opennebula::controller':
#     oneadmin_password => "gavilona", # We must always set the
#                                      # oneadmin_password. I recommend hiera-gpg
#                                      # for storage, not cleartext like this in
#                                      # code.
#     hosts => {
#       # Here we are defining 2 hypervisors that use SCP transfers for image
#       # creation and the KVM virtualisation technology.
#       ["hypervisor1","hypervisor2"] => {
#         "tm_mad" => "tm_ssh",
#         "im_mad" => "im_kvm",
#         "vm_mad" => "vmm_kvm",
#       }
#     },
#     clusters => [
#       # Make a single cluster called 'ibm_blades'
#       "ibm_blades",
#     ],
#     networks => {
#       # Create two vnets with 2 IP addresses using named vlans
#       "vlan300" => { # Internal network perhaps?
#         bridge   => "vlan300", # I recommend creating a named bridge like this
#                                # containing the tagged 802.1q interface for
#                                # vlan300.
#         type     => "fixed",   # That is, _we_ are going to define the IPs
#         public   => true,      # Let every oneuser be able to use this vnet
#         leases   => [
#           "192.168.128.2",     # As we are type => fixed we must define all 
#                                # IPs this way. A function to generate this
#                                # would speed things up.
#           "192.168.128.3",
#         ],
#       }
#       "vlan301" => { # DMZ network
#         bridge   => "vlan301",
#         type     => "fixed",
#         public   => true,
#         leases   => ["192.168.129.2","192.168.129.3"],
#       }
#     },
#     vms => {
#       # Create a high memory and cpu instance for the database, inside the
#       # internal network.
#       "erpdb1" => {
#         memory          => "2048",
#         cpu             => 4,
#         vcpu            => 4,
#         os_arch         => "x86_64",
#         graphics_type   => "vnc",
#         graphics_listen => "0.0.0.0",
#         nics            => [
#           { network => "vlan300",
#             model => "virtio" }, # virtio is the high performance model
#         ],
#         disks           => [
#           { type   => "disk",
#             source => "/srv/one/vms/disks/box1.img",
#             size   => 10000,
#             target => "hda", },
#           # Lets mount say a fibre channel target for database storage
#           { type   => "block",
#             source => "/dev/disk/by-id/erpdb1-db1",
#             target => "hdb", },
#           { type   => "cdrom", 
#             source => "/srv/one/isos/netboot.iso", },
#         ],
#       }
#       # Create a small instance in the DMZ for the web server.
#       "erpweb1" => {
#         memory          => "256",
#         cpu             => 2,
#         vcpu            => 2,
#         os_arch         => "x86_64",
#         graphics_type   => "vnc",
#         graphics_listen => "0.0.0.0",
#         nics            => [
#           { network => "vlan301",
#             model   => "virtio" }, # virtio is the high performance model
#         ],
#         disks           => [
#           { type   => "disk",
#             source => "/srv/one/vms/disks/box1.img",
#             size   => 10000, 
#             target => "hda", },
#           { type   => "cdrom", 
#             source => "/srv/one/isos/netboot.iso", },
#         ],
#       }
#     }
#     images => {
#       "debian-wheezy-64" => {
#         description => "Debian Wheezy 64 bit image",
#         path        => "/srv/one/images/debian-wheezy-64.img",
#         type        => "os",
#       }
#     }
#   }
#
# == Copyright
#
# Copyright 2011-2012 Puppetlabs Inc., unless otherwise noted.
#
class opennebula::controller (

  # Primary parameters
  $oneadmin_password,
  $oned_config = undef,

  # Resource creators
  $clusters = undef,
  $cluster_purge = false,
  $hosts = undef,
  $host_purge = false,
  $networks = undef,
  $network_purge = false,
  $vms = undef,
  $vm_purge = false,
  $images = undef,
  $image_purge = false,

  # Advanced tunables
  $controller_package = $opennebula::params::controller_package,
  $controller_service = $opennebula::params::controller_service,
  $oned_conf_path = $opennebula::params::oned_conf_path,
  $controller_user = $opennebula::params::controller_user,
  $controller_group = $opennebula::params::controller_group,
  $oneadmin_home = $opennebula::params::oneadmin_home

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

  # Setup the root users authentication
  #
  # TODO: we should look up the users home dir somehow
  file { "/root/.one":
    ensure => directory,
  }->
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
  if ($oned_config) {
    # Monopolize create_resources to pass the config hash to the oned_config
    # sub-class.
    $config_hash = { 
      "opennebula::oned_conf" => $oned_config,   
    }
    create_resources("class", $config_hash)
  } else {
    # If not defined, just call oned_conf on its own.
    class { "opennebula::oned_conf": }
  }
  
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
  
  if($clusters) {
    onecluster { $clusters: 
      ensure => present,
    }
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
