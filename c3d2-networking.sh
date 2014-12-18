#!/bin/sh

### LICENSE // ###
#
# Copyright (c) 2014, Daniel Plominski (Plominski IT Consulting)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice, this
# list of conditions and the following disclaimer in the documentation and/or
# other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
### // LICENSE ###

### ### ### PLITC ### ### ###


### stage0 // ###
#
DISTRO=$(uname -a)
DEBIAN=$(uname -a | awk '{print $6}')
DEBVERSION=$(cat /etc/debian_version | cut -c1)
MYNAME=$(whoami)
#
### // stage0 ###

### stage1 // ###
#
case $DEBIAN in
Debian)
   ### Debian ###
#
### stage2 // ###
ARPING=$(/usr/bin/which arping)
ARPSCAN=$(/usr/bin/which arp-scan)
DIALOG=$(/usr/bin/which dialog)
ZSH=$(/usr/bin/which zsh)
IFCONFIG=$(/usr/bin/which ifconfig)
TCPDUMP=$(/usr/bin/which tcpdump)
#
VLAN=$(/usr/bin/dpkg -l | grep vlan | awk '{print $2}')
NETMANAGER=$(/etc/init.d/network-manager status | grep enabled | awk '{print $4}' | sed 's/)//g')
### // stage2 ###
#
### stage3 // ###

if [ $MYNAME = root ]; then
#/echo "" # dummy
   echo "<--- --- --->"
else
   echo "<--- --- --->"
   echo ""
   echo "ERROR: You must be root to run this script"
   exit 1
fi

if [ $DEBVERSION = 8 ]; then
   echo "" # dummy
else
   echo "<--- --- --->"
   echo ""
   echo "ERROR: You need Debian 8 (Jessie) Version"
   exit 1
fi

if [ $NETMANAGER = enabled ]; then
#/echo "Well, your current Setup use an Network-Manager, we don't like it"
#/echo "" # dummy
#/echo "run   /etc/init.d/network-manager stop; update-rc.d network-manager remove; /etc/init.d/networking stop   manually"
#/echo "" # dummy
#/echo "ERROR: network-manager is enabled"
#/sleep 1
#/ exit 1
#
### ### ###
#/(
dialog --title "disable Network-Manager" --backtitle "disable Network-Manager" --yesno "well, your current setup use an network-manager, we don't like that, can we disable it ?" 8 95

response=$?
case $response in
   0)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /etc/init.d/network-manager stop
      update-rc.d network-manager remove
      /etc/init.d/networking stop
      /bin/echo "" # dummy
      systemctl disable NetworkManager
      /bin/echo "" # dummy
      /bin/echo "Network-Manager disabled!"
      sleep 5
#/exit 0
;;
   1)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /bin/echo "ERROR: Network-Manager is enabled!"
      exit 1
;;
   255)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /bin/echo "[ESC] key pressed."
      exit 1
;;
esac
#/)
### ### ###
#
else
   echo "" # dummy
fi

if [ -z $ARPING ]; then
   echo "<--- --- --->"
   echo "need arping"
   echo "<--- --- --->"
   apt-get install -y arping
   cd -
   echo "<--- --- --->"
#/else
#/   echo "" # dummy
fi

if [ -z $ARPSCAN ]; then
   echo "<--- --- --->"
   echo "need arp-scan"
   echo "<--- --- --->"
   apt-get install -y arp-scan
   cd -
   echo "<--- --- --->"
#/else
#/   echo "" # dummy
fi

if [ -z $DIALOG ]; then
   echo "<--- --- --->"
   echo "need dialog"
   echo "<--- --- --->"
   apt-get install -y dialog
   cd -
   echo "<--- --- --->"
#/else
#/   echo "" # dummy
fi

if [ -z $ZSH ]; then
   echo "<--- --- --->"
   echo "need zsh shell"
   echo "<--- --- --->"
   apt-get install -y zsh
   cd -
   echo "<--- --- --->"
#/else
#/   echo "" # dummy
fi

if [ -z $IFCONFIG ]; then
   echo "<--- --- --->"
   echo "need ifconfig"
   echo "<--- --- --->"
   apt-get install -y ifconfig
   cd -
   echo "<--- --- --->"
#/else
#/   echo "" # dummy
fi

if [ -z $TCPDUMP ]; then
    echo "<--- --- --->"
    echo "need tcpdump"
    echo "<--- --- --->"
    apt-get install -y tcpdump
    cd -
    echo "<--- --- --->"
#/else
#/    echo "" # dummy
fi

### vlan // ###
#
if [ -z $VLAN ]; then
    echo "<--- --- --->"
    echo "need vlan"
    echo "<--- --- --->"
    apt-get install -y vlan
    cd -
    echo "<--- --- --->"
#/else
#/    echo "" # dummy
fi
#
#/sleep 1
#
KMODVLAN=$(lsmod | grep 8021q | head -n1 | awk '{print $1}')
#
if [ -z $KMODVLAN ]; then
    echo "" # dummy
    echo "<--- --- --->"
    echo "need vlan kernel module"
    echo "<--- --- --->"
    /sbin/modprobe 8021q
#/cd -
#/echo "<--- --- --->"
#/else
#/echo "" # dummy
fi
#
KMODVLANPERSISTENT=$(cat /etc/modules | grep 8021q)
#
if [ -z $KMODVLANPERSISTENT ]; then
    echo "" # dummy
    echo "<--- --- --->"
    echo "need vlan kernel module on startup"
    echo "<--- --- --->"

/bin/cat <<VLANMOD >> /etc/modules
### vlan // ###
8021q
### // vlan ###
VLANMOD
#/cd -
#/echo "<--- --- --->"
#/else
#/echo "" # dummy
fi
#
### ### ###
IFLIST1="/tmp/c3d2-networking_if_1.txt"
IFLIST2="/tmp/c3d2-networking_if_2.txt"
IFLIST3="/tmp/c3d2-networking_if_3.txt"
#/IFLIST4="/tmp/c3d2-networking_if_4.txt"
#
dmesg | grep eth | egrep "eth0|eth1|eth2" | awk '{print $4}' | sort | uniq | sed 's/://g' > $IFLIST1
nl $IFLIST1 | sed 's/ //g' > $IFLIST2
dialog --menu "Choose one VLAN RAW Interface:" 15 15 15 `cat $IFLIST2` 2>$IFLIST3
#/ GETIF=$(cat $IFLIST3 | cut -c1)
#/ echo $GETIF
/usr/bin/zsh -c "join /tmp/c3d2-networking_if_2.txt /tmp/c3d2-networking_if_3.txt > /tmp/c3d2-networking_if_4.txt"
#
GETIF=$(cat /tmp/c3d2-networking_if_4.txt | awk '{print $2}')
#
INTERFACES=$(cat /etc/network/interfaces | grep "c3d2-networking" | head -n1 | awk '{print $2}')
#
if [ -z $INTERFACES ]; then
    echo "" # dummy
    echo "<--- --- --->"
    echo "write new vlan entries in your /etc/network/interfaces configfile"
    echo "<--- --- --->"
    sed -i -e '/c3d2-networking-vlan-start/,/c3d2-networking-vlan-end/d' /etc/network/interfaces
/bin/cat <<INTERFACEVLAN >> /etc/network/interfaces
### c3d2-networking-vlan-start // ###
#
auto $GETIF.100
iface $GETIF.100 inet manual
#/ iface $GETIF.100 inet6 auto
        vlan-raw-device $GETIF
#
auto $GETIF.101
iface $GETIF.101 inet manual
#/ iface $GETIF.101 inet6 auto
        vlan-raw-device $GETIF
#
auto $GETIF.102
iface $GETIF.102 inet manual
#/ iface $GETIF.102 inet6 auto
        vlan-raw-device $GETIF
#
auto $GETIF.103
iface $GETIF.103 inet manual
#/ iface $GETIF.103 inet6 auto
        vlan-raw-device $GETIF
#
auto $GETIF.104
iface $GETIF.104 inet manual
#/ iface $GETIF.104 inet6 auto
        vlan-raw-device $GETIF
#
auto $GETIF.105
iface $GETIF.105 inet manual
#/ iface $GETIF.105 inet6 auto
        vlan-raw-device $GETIF
#
### // c3d2-networking-vlan-end ###
INTERFACEVLAN
#/cd -
#/echo "<--- --- --->"
#/else
#/echo "" # dummy
fi

### ### ###
#
### // vlan ###


### // stage3 ###
#
### ### ### ### ### ### ### ### ###
   ;;
*)
   # error 1
   echo "<--- --- --->"
   echo ""
   echo "ERROR: Plattform = unknown"
   exit 1
   ;;
esac

#
### // stage1 ###


### ### ### PLITC ### ### ###
# EOF
