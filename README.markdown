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

This class is responsible for setting up the main 'controller' node where oned
runs.

This class can also be passed parameters to configure most aspects of 
OpenNebula:

* Networks
* Clusters
* Hosts
* Images
* Virtual Machines

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

This class should be included on nodes that are designed to run virtual 
machines for the OpenNebula cluster.

#### Examples

Basic example:

    class { "opennebula::node":
    }

### opennebula::econe

This class is for configuring the OpenNebula econe service for emulation of 
the Amazon AWS interface for EC2.

#### Examples

Basic example:

    class { "opennebula::econe":
      one_xmlrpc => "http://oneserver:2633/RPC2",
    }

### opennebula::oned_conf

Oned configuration class. Generally used by the opennebula::controller class
only.

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
    
Context information as well:

    onevnet { "net1":
      type => "ranged",
      bridge => "virbr4",
      public => false,
      network_size => "C",
      network_address => "192.168.55.0",
      context => {
        'gateway' => "192.168.55.254",
      }
    }

    
### onevm

#### Examples

Basic example:

    onevm { "node1":
      memory => "256",
      cpu => 1,
      vcpu => 1,
      os_arch => "x86_64",
      disks => [
        { image => "debian-wheezy-amd64", 
          driver => "qcow2", 
          target => "vda" }
      ],
      graphics_type => "vnc",
      graphics_listen => "0.0.0.0",
      context => {
        hostname => '$NAME',
        gateway => '$NETWORK[GATEWAY]',
        dns => '$NETWORK[DNS]',
        ip => '$NIC[IP]',
        files => '/var/lib/one/context/init.sh',
        target => "vdb",
      }
    }
    
### oneimage

#### Examples

Basic example:

    oneimage { "debian-wheezy-64":
      description => "Debian Wheezy 64 bit image",
      type => "os",
      path => "/srv/images/debian-wheezy-64.img",
    }
