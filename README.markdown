# OpenNebula Module

This module manages OpenNebula from within Puppet.

### Overview

This is the OpenNebula module. Here we are providing capability within Puppet 
to install and configure your OpenNebula clusters.

### Disclaimer

Warning! While this software is written in the best interest of quality it has 
not been formally tested by our QA teams. Use at your own risk, but feel free 
to enjoy and perhaps improve it while you do.

Please see the included Apache Software License for more legal details 
regarding warranty.

### Requirements

So this module was predominantly tested on:

* Puppet 2.7.0rc4
* Debian Wheezy
* OpenNebula 2.0.1

Other combinations may work, and we are happy to obviously take patches to 
support other stacks.

# Installation

As with most modules, its best to download this module from the forge:

http://forge.puppetlabs.com/puppetlabs/opennebula

If you want the bleeding edge (and potentially broken) version from github, 
download the module into your modulepath on your Puppetmaster. If you are not 
sure where your module path is try this command:

    puppet --configprint modulepath

Depending on the version of Puppet, you may need to restart the puppetmasterd 
(or Apache) process before the functions will work.

This module uses both Ruby based providers, functions and it also relies on
exported resources. Configuration must include the following items:

    [master]
    storeconfigs = true
    thin_storeconfigs = true
    dbadapter = mysql
    dbuser = puppet
    dbpassword = password
    dbserver = localhost

And for the agent:

    [agent]
    pluginsync = true
    
The module will not operate normally without these features.

# Quick Start

Setup the controller.

    node "oneserver" {
      class { "opennebula::controller":
        oneadmin_password => "mypassword",
      }
    }

Setup a node.

    node "kvm1" {
      # You will need to configure libvirt and kvm (for example)
      class { "kvm":
      }
      class { "libvirt":
      }
    
      class { "opennebula::node": 
        controller => "oneserver",
      }
    }

Setup an econe server:

    node "econe1" {
      class { "opennebula::econe":
        one_xmlrpc => "http://oneserver:2633/RPC2",
      }
    }

Setup up the Sunstone web interface:

    node "controller1":
      class { "opennebula::sunstone": }
    }

This will be available on http://$fqdn:4568/.
    
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

Adding hooks for dynamic DNS can be done using the oned_config->hooks parameter area. 

This allows you to have Opennebula automatically update DNS when nodes are created
and remove DNS entries when nodes are destroyed:

    class { "opennebula::controller":
      oneadmin_password => "something",
      oned_config => {
        hooks => {
          'dnsupdate' => {
            on => "running",
            command => "/usr/share/one/hooks/puppet/dnsupdate.rb",
            arguments => 'vms.cloud.mydomain.com 1.1.1.1 $NAME $NIC[IP]',
            remote => "no",
          },
          'dnsdelete' => {
            on => "done",
            command => "/usr/share/one/hooks/puppet/dnsdelete.rb",
            arguments => 'vms.cloud.mydomain.com 1.1.1.1 $NAME',
            remote => "no",
          },
        },
      },
    }

### opennebula::node

This class should be included on nodes that are designed to run virtual 
machines for the OpenNebula cluster.

You have to specify a controller for the node to peer with.

#### Examples

Basic example:

    class { "opennebula::node":
      controller => "one1.mydomain.com",
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

### opennebula::sunstone

This class configures sunstone to run on port 4568:

http://$fqdn:4568/

#### Examples

Sunstone takes no options:

    class { "opennebula::sunstone": }

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

## Facts

### one_context_path

This fact returns the path to the context file on the machine. It is designed
for use on virtual machines launched by OpenNebula.

### one_context_var_*

These facts are returned from the contents of your context.sh file (see fact
above). It allows someone in Puppet to use variables passed to a VM using
OpenNebula contexts.

### oneadmin_pubkey_rsa

This fact returns the contents of the oneadmin users public key. This can be
used to create SSH trusts between OpenNebula nodes and controllers by exporting 
a resource using this fact as the contents for creating authorized key entries.
