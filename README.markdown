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
        class { "opennebula::node": }
    }
