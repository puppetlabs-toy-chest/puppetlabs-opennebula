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