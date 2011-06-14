# OpenNebula Module

This module manages OpenNebula from within Puppet.

# Quick Start

Setup the controller.

    node "oneserver" {
      class { "opennebula::controller":
        oneadmin_password => "mypassword",
      }
    }

Setup a node.

    node "kvm1" {
      class { "opennebula::node": 
      }
    }

Setup an econe server:

    node "econe1" {
      class { "opennebula::econe":
        one_xmlrpc => "http://oneserver:2633/RPC2",
      }
    }
    
# Detailed Usage

## Class based versus resource based

The module is designed to allow you to configure everything during class
instantiation time or configure elements later using individual resources.

## Classes

### opennebula::controller

#### Examples

Basic example:

    class { "opennebula::controller":
      oneadmin_password => "mypassword",
    }
    
Configuring clusters, networks and hosts all at the same time:

    class { "opennebula::controller":
      oneadmin_password => "mypassword",
      networks => {
        "net1" => {
          type => "ranged",
          public => false,
          bridge => "vlan24",
          network_size => "C",
          network_address => "192.168.45.0",
        }
      },
      hosts => {
        "node1" => {
          im_mad => "im_kvm",
          tm_mad => "tm_ssh",
          vm_mad => "vmm_kvm",
        }
      }
      clusters => [ "smallboxes", "bigboxes" ],
    }
    
Configuring a different storage backend:

    class { "opennebula::controller":
      oneadmin_password => "something",
      oned_config => {
        'db_backend' => 'mysql',
        'db_server' => 'localhost',
        'db_user' => 'opennebula',
        'db_passwd' => 'opennebula',
        'db_name' => 'opennebula',
      },
    }

### opennebula::node

#### Examples

Basic example:

    class { "opennebula::node":
    }

### opennebula::econe

#### Examples

Basic example:

    class { "opennebula::econe":
      one_xmlrpc => "http://oneserver:2633/RPC2",
    }

### opennebula::oned_conf

## Resources

### onecluster

#### Examples

Basic example:

    onecluster { "bigboxes":
    }

### onehost

#### Examples

Basic example:

    onehost { "node1":
      im_mad => "im_kvm",
      tm_mad => "tm_ssh",
      vm_mad => "vmm_kvm",
    }

### onevnet

#### Examples

Basic example:

    onevnet { "net1":
      type => "ranged",
      bridge => "virbr4",
      public => false,
      network_size => "C",
      network_address => "192.168.55.0",
    }
    
### onevm

#### Examples

Basic example:

    onevm { "node1":
      memory => "256",
      cpu => 1,
      vcpu => 1,
      os_arch => "x86_64",
    }
    
### oneimage

#### Examples

Basic example:

    oneimage { "debian-wheezy-64":
      description => "Debian Wheezy 64 bit image",
      type => "os",
      path => "/srv/images/debian-wheezy-64.img",
    }