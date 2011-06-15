#!/bin/bash

# -------------------------------------------------------------------------- #
# Copyright 2002-2011, OpenNebula Project Leads (OpenNebula.org)             #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#--------------------------------------------------------------------------- #

# Gets IP address from a given MAC
mac2ip() {
    mac=$1
 
    let ip_a=0x`echo $mac | cut -d: -f 3`
    let ip_b=0x`echo $mac | cut -d: -f 4`
    let ip_c=0x`echo $mac | cut -d: -f 5`
    let ip_d=0x`echo $mac | cut -d: -f 6`
 
    ip="$ip_a.$ip_b.$ip_c.$ip_d"
 
    echo $ip
}
 
# Gets the network part of an IP
get_network() {
    IP=$1
 
    echo $IP | cut -d'.' -f1,2,3
}
 
get_interfaces() {
    IFCMD="/sbin/ifconfig -a"
 
    $IFCMD | grep ^eth | sed 's/ *Link encap:Ethernet.*HWaddr /-/g'
}
 
get_dev() {
    echo $1 | cut -d'-' -f 1
}
 
get_mac() {
    echo $1 | cut -d'-' -f 2
}
 
gen_hosts() {
    echo "127.0.0.1 localhost"
    echo "${IP} ${HOSTNAME}"
    echo ""
    echo "# IPv6 Specific stuff"
    echo "::1 ip6-localhost ip6-loopback"
    echo "fe00::0 ip6-localnet"
    echo "ff00::0 ip6-mcastprefix"
    echo "ff02::1 ip6-allnodes"
    echo "ff02::2 ip6-allrouters"
}
 
gen_interface() {
    DEV_MAC=$1
    DEV=`get_dev $DEV_MAC`
    MAC=`get_mac $DEV_MAC`
    IP=`mac2ip $MAC`
    NETWORK=`get_network $IP`
 
    cat <<EOT
auto $DEV
iface $DEV inet static
  address $IP
  network $NETWORK.0
  netmask 255.255.255.0
EOT
 
    if [ $DEV == "eth0" ]; then
      echo "  gateway $NETWORK.1"
    fi
 
echo ""
}

if [ -f /srv/onecontext/context.sh ]; then
  . /srv/onecontext/context.sh
fi
 
 
IFACES=`get_interfaces`
 
for i in $IFACES; do
    MASTER_DEV_MAC=$i
    DEV=`get_dev $i`
    MAC=`get_mac $i`
    IP=`mac2ip $MAC`
    NETWORK=`get_network $IP`
done
 
gen_hosts > /etc/hosts
 
# Networking
(
cat <<EOT
auto lo
iface lo inet loopback
 
EOT
 
for i in $IFACES; do
    gen_interface $i
done
) > /etc/network/interfaces

# Hostname

echo $HOSTNAME > /etc/hostname
 
/bin/hostname `cat /etc/hostname`

# Restart networking last
service networking restart
