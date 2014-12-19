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
DISTRO=$(uname -a)
DEBIAN=$(uname -a | awk '{print $6}')
DEBVERSION=$(cat /etc/debian_version | cut -c1)
MYNAME=$(whoami)
### // stage0 ###
#
### stage1 // ###
case $DEBIAN in
Debian)
### stage2 // ###
ARPING=$(/usr/bin/which arping)
ARPSCAN=$(/usr/bin/which arp-scan)
DIALOG=$(/usr/bin/which dialog)
ZSH=$(/usr/bin/which zsh)
IFCONFIG=$(/usr/bin/which ifconfig)
TCPDUMP=$(/usr/bin/which tcpdump)
VLAN=$(/usr/bin/dpkg -l | grep vlan | awk '{print $2}')
NETMANAGER=$(/etc/init.d/network-manager status | grep enabled | awk '{print $4}' | sed 's/)//g')
BACKUPDATE=$(date +%Y-%m-%d-%H%M%S)
### // stage2 ###
#
### stage3 // ###
if [ "$MYNAME" = "root" ]; then
#/ echo "" # dummy
   echo "<--- --- --->"
else
   echo "<--- --- --->"
   echo ""
   echo "ERROR: You must be root to run this script"
   exit 1
fi
if [ "$DEBVERSION" = "8" ]; then
   echo "" # dummy
else
   echo "<--- --- --->"
   echo ""
   echo "ERROR: You need Debian 8 (Jessie) Version"
   exit 1
fi
if [ X"$NETMANAGER" = X"enabled" ]; then
#/ echo "Well, your current Setup use an Network-Manager, we don't like it"
#/ echo "" # dummy
#/ echo "run   /etc/init.d/network-manager stop; update-rc.d network-manager remove; /etc/init.d/networking stop   manually"
#/ echo "" # dummy
#/ echo "ERROR: network-manager is enabled"
#/ sleep 1
#/ exit 1
#/ (
dialog --title "disable Network-Manager" --backtitle "disable Network-Manager" --yesno "well, your current setup use an network-manager, we don't like that, can we disable it ?" 8 95
#
response1=$?
case $response1 in
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
      /bin/echo "" # dummy
      echo "<--- --- --->"
      echo "write a new /etc/network/interfaces config file"
      echo "<--- --- --->"
      cp -pf /etc/network/interfaces /etc/network/interfaces_$BACKUPDATE
      touch /tmp/c3d2-networking_new_config.txt
/bin/cat <<INTERFACELOOPBACK > /etc/network/interfaces
### loopback // ###
auto lo
iface lo inet loopback
### // loopback ###
#
INTERFACELOOPBACK
#/ ETH0=$(dmesg | egrep "eth0" | egrep -v "ifname" | awk '{print $5}' | head -n 1 | sed 's/://g')
#/ ETH1=$(dmesg | egrep "eth1" | egrep -v "ifname" | awk '{print $5}' | head -n 1 | sed 's/://g')
#/ ETH2=$(dmesg | egrep "eth2" | egrep -v "ifname" | awk '{print $5}' | head -n 1 | sed 's/://g')
#/ WLAN0=$(dmesg | egrep "wlan0" | egrep -v "ifname" | awk '{print $3}' | head -n 1 | sed 's/://g')
ETH=$(lspci | grep "Ethernet" | wc -l)
WLAN=$(lspci | grep "Wireless" | wc -l)
if [ X"$ETH" = X"1" ]; then
#/ echo "" # dummy
#/ else
/bin/cat <<INTERFACEETH0 >> /etc/network/interfaces
### eth0 // ###
auto eth0
iface eth0 inet dhcp
iface eth0 inet6 auto
### // eth0 ###
#
INTERFACEETH0
fi
if [ X"$ETH" = X"2" ]; then
#/ echo "" # dummy
#/ else
/bin/cat <<INTERFACEETH1 >> /etc/network/interfaces
### eth1 // ###
auto eth1
iface eth1 inet dhcp
iface eth1 inet6 auto
### // eth1 ###
#
INTERFACEETH1
fi
if [ X"$ETH" = X"3" ]; then
#/ echo "" # dummy
#/ else
/bin/cat <<INTERFACEETH2 >> /etc/network/interfaces
### eth2 // ###
auto eth2
iface eth2 inet dhcp
iface eth2 inet6 auto
### // eth2 ###
#
INTERFACEETH2
fi
if [ X"$WLAN" = X"1" ]; then
#/ echo "" # dummy
#/ else
/bin/cat <<INTERFACEWLAN0 >> /etc/network/interfaces
### wlan0 // ###
auto wlan0
iface wlan0 inet dhcp
iface wlan0 inet6 auto
wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
### // wlan0 ###
#
INTERFACEWLAN0
fi
#/ exit 0
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
#/ )
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
#/ else
#/ echo "" # dummy
fi
if [ -z $ARPSCAN ]; then
   echo "<--- --- --->"
   echo "need arp-scan"
   echo "<--- --- --->"
   apt-get install -y arp-scan
   cd -
   echo "<--- --- --->"
#/ else
#/ echo "" # dummy
fi
if [ -z $DIALOG ]; then
   echo "<--- --- --->"
   echo "need dialog"
   echo "<--- --- --->"
   apt-get install -y dialog
   cd -
   echo "<--- --- --->"
#/ else
#/ echo "" # dummy
fi
if [ -z $ZSH ]; then
   echo "<--- --- --->"
   echo "need zsh shell"
   echo "<--- --- --->"
   apt-get install -y zsh
   cd -
   echo "<--- --- --->"
#/ else
#/ echo "" # dummy
fi
if [ -z $IFCONFIG ]; then
   echo "<--- --- --->"
   echo "need ifconfig"
   echo "<--- --- --->"
   apt-get install -y ifconfig
   cd -
   echo "<--- --- --->"
#/ else
#/ echo "" # dummy
fi
if [ -z $TCPDUMP ]; then
    echo "<--- --- --->"
    echo "need tcpdump"
    echo "<--- --- --->"
    apt-get install -y tcpdump
    cd -
    echo "<--- --- --->"
#/ else
#/ echo "" # dummy
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
#/ else
#/ echo "" # dummy
fi
#/ sleep 1
KMODVLAN=$(lsmod | grep 8021q | head -n1 | awk '{print $1}')
if [ -z $KMODVLAN ]; then
    echo "" # dummy
    echo "<--- --- --->"
    echo "need vlan kernel module"
    echo "<--- --- --->"
    /sbin/modprobe 8021q
#/ cd -
#/ echo "<--- --- --->"
#/ else
#/ echo "" # dummy
fi
KMODVLANPERSISTENT=$(cat /etc/modules | grep 8021q)
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
#/ cd -
#/ echo "<--- --- --->"
#/ else
#/ echo "" # dummy
fi
ETHN=$(lspci | grep "Ethernet" | wc -l)
WLANN=$(lspci | grep "Wireless" | wc -l)
if [ X"$ETHN" = X"1" ]; then
   echo "eth0" > /tmp/c3d2-networking_if_1.txt
fi
if [ X"$ETHN" = X"2" ]; then
   echo "eth0" > /tmp/c3d2-networking_if_1.txt
   echo "eth1" >> /tmp/c3d2-networking_if_1.txt
fi
if [ X"$ETHN" = X"3" ]; then
   echo "eth0" > /tmp/c3d2-networking_if_1.txt
   echo "eth1" >> /tmp/c3d2-networking_if_1.txt
   echo "eth2" >> /tmp/c3d2-networking_if_1.txt
fi
if [ X"$WLANN" = X"1" ]; then
   WPAFILE="/etc/wpa_supplicant/wpa_supplicant.conf"
   if [ -e $WPAFILE ]; then
      cp -pf /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf_$BACKUPDATE
      chmod 0600 /etc/wpa_supplicant/wpa_supplicant.conf_*
   else
      touch $WPAFILE
      chmod 0600 $WPAFILE
   fi
   WPAC3D2=$(cat /etc/wpa_supplicant/wpa_supplicant.conf | grep 'ssid="C3D2"')
   if [ -z "$WPAC3D2" ]; then
/bin/cat <<WPAC3D2INPUT >> /etc/wpa_supplicant/wpa_supplicant.conf
### C3D2 Wireless Network // ###
network={
        ssid="C3D2"
        key_mgmt=NONE
        priority=10
        id_str="C3D2"
}
network={
        ssid="C3D2 5"
        key_mgmt=NONE
        priority=11
}
### // C3D2 Wireless Network ###
WPAC3D2INPUT
   fi
fi
#/ touch /tmp/c3d2-networking_if_1.txt
IFLIST1="/tmp/c3d2-networking_if_1.txt"
IFLIST2="/tmp/c3d2-networking_if_2.txt"
IFLIST3="/tmp/c3d2-networking_if_3.txt"
#/ IFLIST4="/tmp/c3d2-networking_if_4.txt"
#/ touch $IFLIST1
#/ dmesg | egrep "eth0|eth1|eth2" | egrep -v "ifname" | awk '{print $5}' | sort | uniq | sed 's/://g' > $IFLIST1
#/ if [ -e $IFLIST1 ]; then
#/    echo "" # dummy
#/    echo "WARNING: can't analyse the network device information from dmesg"
#/    sleep 2
#/ exit 1
#/ fi
nl $IFLIST1 | sed 's/ //g' > $IFLIST2
dialog --menu "Choose one VLAN RAW Interface:" 15 15 15 `cat $IFLIST2` 2>$IFLIST3
#/ GETIF=$(cat $IFLIST3 | cut -c1)
#/ echo $GETIF
/usr/bin/zsh -c "join /tmp/c3d2-networking_if_2.txt /tmp/c3d2-networking_if_3.txt > /tmp/c3d2-networking_if_4.txt"
GETIF=$(cat /tmp/c3d2-networking_if_4.txt | awk '{print $2}')
INTERFACES=$(cat /etc/network/interfaces | grep "c3d2-networking" | head -n1 | awk '{print $2}')
if [ -z $INTERFACES ]; then
    echo "" # dummy
    echo "<--- --- --->"
    echo "write new vlan entries in your /etc/network/interfaces config file"
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
### // vlan ###
CONFIGCHECK="/tmp/c3d2-networking_new_config.txt"
if [ -e $CONFIGCHECK ]; then
   rm -f /tmp/c3d2-networking_new_config.txt
IFSTART=50
(
while test $IFSTART != 150
do
echo $IFSTART
echo "XXX"
echo "we try to start your interfaces (wait a minute) : ($IFSTART percent)"
echo "XXX"
### run // ###
/etc/init.d/networking start
### // run ###
IFSTART=`expr $IFSTART + 50`
sleep 1
done
) | dialog --title "/etc/init.d/networking start" --gauge "/etc/init.d/networking start" 20 70 0
IFCHECK=$(systemctl is-active networking)
  if [ X"$IFCHECK" = X"active" ]; then
   echo "" # dummy
   echo "" # dummy
   echo "It works"
   sleep 2
   /sbin/ifconfig > /tmp/c3d2-networking_ifconfig1.txt
   IFCONFIG1="/tmp/c3d2-networking_ifconfig1.txt"
   dialog --textbox "$IFCONFIG1" 0 0
  else
   dialog --title "new network config" --backtitle "new network config" --infobox "you've got a new network config file, please reboot your system immediately..." 3 82
   echo "" # dummy
   echo "" # dummy
   echo "ERROR: Reboot your System immediately!"
   exit 1
  fi
fi
### clean up 1 // ###
rm -f /tmp/c3d2-networking*
### // clean up 1 ###
#
### stage4 // ###
#
IPCHECK=$(ip a | grep "inet" | egrep -v "127.0.0.1" | awk '{print $2}' | head -n 1)
if [ -z "$IPCHECK" ]; then
   echo "" # FUU
else

dialog --title "get_ipv4_address (experimental)" --backtitle "get_ipv4_address (experimental)" --yesno "well, none of your interface has an ip address, we can try manually" 5 72
response2=$?
case $response2 in
   0)
### get_ipv4_address // ###
(
### stage5 // ###
rm -rf /tmp/get_ipv4*
GETIPV4="/tmp/get_ipv4_address.log"
touch $GETIPV4
GETIPV4ROUTER="/tmp/get_ipv4_router.log"
touch $GETIPV4ROUTER
GETIPV4ROUTERLIST="/tmp/get_ipv4_router_list.log"
touch $GETIPV4ROUTERLIST
GETIPV4ROUTERLISTMENU="/tmp/get_ipv4_router_list_menu.log"
touch $GETIPV4ROUTERLISTMENU
GETIPV4DNSLIST="/tmp/get_ipv4_dnslist.log"
touch $GETIPV4DNSLIST
GETIPV4ARPDIG="/tmp/get_ipv4_address_arpdig.log"
touch $GETIPV4ARPDIG
## DN42a // ##
GETIPV4CURRDN42ALIST="/tmp/get_ipv4_address_currdn42a.log"
touch $GETIPV4CURRDN42ALIST
GETIPV4FULLDN42ALIST="/tmp/get_ipv4_address_fulldn42a.log"
touch $GETIPV4FULLDN42ALIST
GETIPV4CURRDN42ALISTL="/tmp/get_ipv4_address_currdn42a_l.log"
touch $GETIPV4CURRDN42ALISTL
GETIPV4FULLDN42ALISTL="/tmp/get_ipv4_address_fulldn42a_l.log"
touch $GETIPV4FULLDN42ALISTL
GETIPV4SORTDN42ALISTL="/tmp/get_ipv4_address_sortdn42a.log"
touch $GETIPV4SORTDN42ALISTL
GETIPV4MENUDN42A="/tmp/get_ipv4_address_menudn42a.log"
touch $GETIPV4MENUDN42A
GETIPV4MENUDN42ALIST="/tmp/get_ipv4_address_menudn42alist.log"
touch $GETIPV4MENUDN42ALIST
GETIPV4MENUDN42ALISTIP="/tmp/get_ipv4_address_menudn42a_ip.log"
touch $GETIPV4MENUDN42ALISTIP
GETIPV4MENUDN42AIPFUNC="/tmp/get_ipv4_address_menudn42a_ipfunc.log"
touch $GETIPV4MENUDN42AIPFUNC
## // DN42a ##
## Class A // ##
GETIPV4CURRALIST="/tmp/get_ipv4_address_curra.log"
touch $GETIPV4CURRALIST
GETIPV4FULLALIST="/tmp/get_ipv4_address_fulla.log"
touch $GETIPV4FULLALIST
GETIPV4CURRALISTL="/tmp/get_ipv4_address_curra_l.log"
touch $GETIPV4CURRALISTL
GETIPV4FULLALISTL="/tmp/get_ipv4_address_fulla_l.log"
touch $GETIPV4FULLALISTL
GETIPV4SORTALISTL="/tmp/get_ipv4_address_sorta.log"
touch $GETIPV4SORTALISTL
GETIPV4MENUA="/tmp/get_ipv4_address_menua.log"
touch $GETIPV4MENUA
GETIPV4MENUALIST="/tmp/get_ipv4_address_menualist.log"
touch $GETIPV4MENUALIST
GETIPV4MENUALISTIP="/tmp/get_ipv4_address_menua_ip.log"
touch $GETIPV4MENUALISTIP
GETIPV4MENUAIPFUNC="/tmp/get_ipv4_address_menua_ipfunc.log"
touch $GETIPV4MENUAIPFUNC
## // Class A ##
## Class B // ##
GETIPV4CURRBLIST="/tmp/get_ipv4_address_currb.log"
touch $GETIPV4CURRBLIST
GETIPV4FULLBLIST="/tmp/get_ipv4_address_fullb.log"
touch $GETIPV4FULLBLIST
GETIPV4CURRBLISTL="/tmp/get_ipv4_address_currb_l.log"
touch $GETIPV4CURRBLISTL
GETIPV4FULLBLISTL="/tmp/get_ipv4_address_fullb_l.log"
touch $GETIPV4FULLBLISTL
GETIPV4SORTBLISTL="/tmp/get_ipv4_address_sortb.log"
touch $GETIPV4SORTBLISTL
GETIPV4MENUB="/tmp/get_ipv4_address_menub.log"
touch $GETIPV4MENUB
GETIPV4MENUBLIST="/tmp/get_ipv4_address_menublist.log"
touch $GETIPV4MENUBLIST
GETIPV4MENUBLISTIP="/tmp/get_ipv4_address_menub_ip.log"
touch $GETIPV4MENUBLISTIP
GETIPV4MENUBIPFUNC="/tmp/get_ipv4_address_menub_ipfunc.log"
touch $GETIPV4MENUBIPFUNC
## // Class B ##
## Class C // ##
GETIPV4CURRCLIST="/tmp/get_ipv4_address_currc.log"
touch $GETIPV4CURRCLIST
GETIPV4FULLCLIST="/tmp/get_ipv4_address_fullc.log"
touch $GETIPV4FULLCLIST
GETIPV4CURRCLISTL="/tmp/get_ipv4_address_currc_l.log"
touch $GETIPV4CURRCLISTL
GETIPV4FULLCLISTL="/tmp/get_ipv4_address_fullc_l.log"
touch $GETIPV4FULLCLISTL
GETIPV4SORTCLISTL="/tmp/get_ipv4_address_sortc.log"
touch $GETIPV4SORTCLISTL
GETIPV4MENUC="/tmp/get_ipv4_address_menuc.log"
touch $GETIPV4MENUC
GETIPV4MENUCLIST="/tmp/get_ipv4_address_menuclist.log"
touch $GETIPV4MENUCLIST
GETIPV4MENUCLISTIP="/tmp/get_ipv4_address_menuc_ip.log"
touch $GETIPV4MENUCLISTIP
GETIPV4MENUCIPFUNC="/tmp/get_ipv4_address_menuc_ipfunc.log"
touch $GETIPV4MENUCIPFUNC
## // Class C ##
### // stage5 ###


### stage6 // ###
### show if list // ###
#/ /sbin/ifconfig -a | grep "Link" | egrep -v "lo" | awk '{print $1}' > /tmp/c3d2-networking_ifconfig2.txt
#/ IFCONFIG2="/tmp/c3d2-networking_ifconfig2.txt"
#/ dialog --backtitle "show available interfaces" --textbox "$IFCONFIG2" 0 0
dialog --radiolist "Select on Interface:" 15 75 12 \
   1 "eth0       (regular environment - untagged / vlan forbidden)" on\
   2 "wlan0      (regular environment)" off\
   3 "eth0.100   (vlan100 - hq ipv4 telekom / ipv6 sixxs)" off\
   4 "eth0.101   (vlan101 - hq ipv4 ipredator / ipv6 ipredator)" off\
   5 "eth0.102   (vlan102 - hq testing network)" off\
   6 "eth0.103   (vlan103 - hq testing network)" off\
   7 "eth0.104   (vlan104 - hq testing network)" off\
   8 "eth0.105   (vlan105 - hq testing network)" off\
    2>/tmp/c3d2-networking_ifconfig3.txt
cat /tmp/c3d2-networking_ifconfig3.txt | cut -c1 > /tmp/c3d2-networking_ifconfig4.txt
IFCHOOSELIST="/tmp/c3d2-networking_ifconfig5.txt"
/bin/echo "1 eth0" > $IFCHOOSELIST
/bin/echo "2 wlan0" >> $IFCHOOSELIST
/bin/echo "3 eth0.100" >> $IFCHOOSELIST
/bin/echo "4 eth0.101" >> $IFCHOOSELIST
/bin/echo "5 eth0.102" >> $IFCHOOSELIST
/bin/echo "6 eth0.103" >> $IFCHOOSELIST
/bin/echo "7 eth0.104" >> $IFCHOOSELIST
/bin/echo "8 eth0.105" >> $IFCHOOSELIST
/usr/bin/zsh -c "join /tmp/c3d2-networking_ifconfig4.txt /tmp/c3d2-networking_ifconfig5.txt > /tmp/c3d2-networking_ifconfig6.txt"
sleep 1
GETIPV4IFVALUE=$(cat /tmp/c3d2-networking_ifconfig6.txt | awk '{print $2}')
### // show if list ###
GETIPV4IF="/tmp/get_ipv4_address_if.log"
touch $GETIPV4IF
#/ dialog --inputbox "Enter the interface name:" 8 40 2>$GETIPV4IF
#/ GETIPV4IFVALUE=$(cat $GETIPV4IF | sed 's/#//g' | sed 's/%//g')
#/ GETIPV4IFCHECK=$(ifconfig -a | grep "Link" | egrep -v "lo" | awk '{print $1}' | sed 's/://g' | grep $GETIPV4IFVALUE)
#/ if [ -z "$GETIPV4IFCHECK" ]; then
#/    echo "" # dummy
#/    echo "" # dummy
#/    echo "ERROR: interface doesn't exist or isn't showing up"
#/    exit 1
#/ else
#/ echo "" # dummy
#/ fi
/sbin/ifconfig $GETIPV4IFVALUE up
### // stage6 ###


### stage7 // ###

### kill dhclient // ###
killall -q dhclient
### // kill dhclient ###

   #echo "<--- tcpdump preview // --->"
   #echo ""
   #/usr/sbin/tcpdump -e -n -i $GETIPV4IFVALUE -c 25 | grep --color 0x0800
   #echo ""
   #echo "<--- // tcpdump preview --->"
   #echo ""
   #(/usr/sbin/tcpdump -e -n -i $GETIPV4IFVALUE -c 5 | grep "0x0800" | awk '{print $10}' 2>&1 > $GETIPV4) &&
   #(/usr/sbin/tcpdump -e -n -i $GETIPV4IFVALUE -c 5 | grep "0x0806" | awk '{print $12}' 2>&1 >> $GETIPV4) &&
   #echo ""

TCPDUMP1=10
(
while test $TCPDUMP1 != 110
do
echo $TCPDUMP1
echo "XXX"
echo "discovering the local network: ($TCPDUMP1 percent)"
echo "XXX"
### run // ###
   echo "" > $GETIPV4
   ( (/usr/sbin/tcpdump -e -n -i $GETIPV4IFVALUE -c 4 | egrep "0x0800|0x0806") >> $GETIPV4 2>&1) &
   #/sleep 1
   #/( (/usr/sbin/tcpdump -e -n -i $GETIPV4IFVALUE -c 2 | grep "0x0806" | awk '{print $12}') >> $GETIPV4 2>&1) &&
### // run ###
TCPDUMP1=`expr $TCPDUMP1 + 10`
sleep 1
done
) | dialog --title "tcpdump - network discovery" --gauge "discover the local network" 20 70 0

echo "<--- --- --- --- --- --- --- --- --->"

CLASSCTEST=$(grep -F "192.168." $GETIPV4 | wc -l | sed 's/ //g')
CLASSBTEST=$(grep -F "172.16." $GETIPV4 | wc -l | sed 's/ //g')
CLASSATEST=$(grep -F "10." $GETIPV4 | wc -l | sed 's/ //g')
CLASSDN42ATEST=$(grep -F "172.22." $GETIPV4 | wc -l | sed 's/ //g')

if [ $CLASSCTEST = 0 ]; then
   echo "ERROR: can't find class C network, try again ..."
   echo "<--- --- --->"
###
   if [ $CLASSBTEST = 0 ]; then
      echo "ERROR: can't find class B network, try again ..."
      echo "<--- --- --->"
### ###
      if [ $CLASSATEST = 0 ]; then
         echo "ERROR: can't find class A network, try again ..."
         echo "<--- --- --->"
### ### ###
            echo 'ERROR: no RFC1918 networks found, try dn42 ...'
            # exit 1
            echo "<--- --- --->"
### ### ### DN42a // ### ### ###
               if [ $CLASSDN42ATEST = 0 ]; then
                  echo "ERROR: ... doesn't work ... the tcpdump lookup was probably too short, try again"
                  echo "<--- --- --->"
                  exit 1
### ### ### ### ### ###
               else
                  echo 'looks like ... DN42 A network'
# <--- --- --- --- --- --- --- --- ---//
   CLASSDN42ANET=$(cat $GETIPV4 | grep "172.22" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "0.0.0.0" | sort | uniq | head -n 1 | awk -F. '{print $1"."$2"."$3}' | xargs -L1 -I {} echo {}.0/24)
   # /usr/bin/arp-scan -I $GETIPV4IFVALUE $CLASSDN42ANET
   /usr/bin/arp-scan -I $GETIPV4IFVALUE $CLASSDN42ANET > $GETIPV4ARPDIG
   CLASSDN42APRE=$(cat $GETIPV4 | grep "172.22" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "0.0.0.0" | sort | uniq | head -n 1 | awk -F. '{print $1"."$2"."$3}')
   GETIPV4CURRDN42A=$(cat $GETIPV4ARPDIG | grep "172.22" | awk '{print $1}' | sort)
   netdn42a=$CLASSDN42APRE; idn42a=1; GETIPV4FULLDN42A=`while [ $idn42a -lt 255 ]; do echo $netdn42a.$idn42a; idn42a=$(($idn42a+1)); done`
   echo $GETIPV4CURRDN42A > $GETIPV4CURRDN42ALIST
   echo $GETIPV4FULLDN42A > $GETIPV4FULLDN42ALIST
   tr ' ' '\n' < $GETIPV4CURRDN42ALIST > $GETIPV4CURRDN42ALISTL
   tr ' ' '\n' < $GETIPV4FULLDN42ALIST > $GETIPV4FULLDN42ALISTL
   sort -n $GETIPV4CURRDN42ALISTL $GETIPV4FULLDN42ALISTL | uniq -u > $GETIPV4SORTDN42ALISTL
   nl $GETIPV4SORTDN42ALISTL | sed 's/ //g' > $GETIPV4MENUDN42A
   dialog --menu "Choose one (free) IP:" 45 45 40 `cat $GETIPV4MENUDN42A` 2>$GETIPV4MENUDN42ALIST
   /usr/bin/zsh -c "join /tmp/get_ipv4_address_menudn42a.log /tmp/get_ipv4_address_menudn42alist.log > /tmp/get_ipv4_address_menudn42a_ip.log"
   SETDN42AIP=$(cat /tmp/get_ipv4_address_menudn42a_ip.log | awk '{print $2}')
   dialog --menu "IP function:" 10 10 10 1 new 2 alias 2>$GETIPV4MENUDN42AIPFUNC
   GETIPV4MENUDN42AIPFUNCN=$(cat $GETIPV4MENUDN42AIPFUNC | sed 's/#//g' | sed 's/%//g')
   if [ $GETIPV4MENUDN42AIPFUNCN = 1 ]; then
#      ###
#      ###
#      ###
#      ###
      ip addr flush dev $GETIPV4IFVALUE
      ip addr add $SETDN42AIP/24 dev $GETIPV4IFVALUE
   else
      ip addr add $SETDN42AIP/24 dev $GETIPV4IFVALUE
   fi
### ### ### ### ### ### ### ### ###
NEWDN42AIP=$(ip addr show $GETIPV4IFVALUE | grep --color $SETDN42AIP)
echo ""
ip addr show $GETIPV4IFVALUE
echo ""
echo "Your new IP: $NEWDN42AIP"
### ### ### ### ### ### ### ### ###
# <// --- --- --- --- --- --- --- --- ---
#
### ### ### // DN42a ### ### ###
               fi
### ### ###
      else
         echo 'looks like ... class A network'
# <--- --- --- --- --- --- --- --- ---//
   CLASSANET=$(cat $GETIPV4 | grep "10." | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "0.0.0.0" | sort | uniq | head -n 1 | awk -F. '{print $1"."$2"."$3}' | xargs -L1 -I {} echo {}.0/24)
   # /usr/bin/arp-scan -I $GETIPV4IFVALUE $CLASSANET  
   /usr/bin/arp-scan -I $GETIPV4IFVALUE $CLASSANET > $GETIPV4ARPDIG
   CLASSAPRE=$(cat $GETIPV4 | grep "10." | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "0.0.0.0" | sort | uniq | head -n 1 | awk -F. '{print $1"."$2"."$3}')
   GETIPV4CURRA=$(cat $GETIPV4ARPDIG | grep "10." | awk '{print $1}' | sort)
   neta1=$CLASSAPRE; ia1=1; GETIPV4FULLA=`while [ $ia1 -lt 255 ]; do echo $neta1.$ia1; ia1=$(($ia1+1)); done`
   echo $GETIPV4CURRA > $GETIPV4CURRALIST
   echo $GETIPV4FULLA > $GETIPV4FULLALIST
   tr ' ' '\n' < $GETIPV4CURRALIST > $GETIPV4CURRALISTL
   tr ' ' '\n' < $GETIPV4FULLALIST > $GETIPV4FULLALISTL
   sort -n $GETIPV4CURRALISTL $GETIPV4FULLALISTL | uniq -u > $GETIPV4SORTALISTL
   nl $GETIPV4SORTALISTL | sed 's/ //g' > $GETIPV4MENUA
   dialog --menu "Choose one (free) IP:" 45 45 40 `cat $GETIPV4MENUA` 2>$GETIPV4MENUALIST
   /usr/bin/zsh -c "join /tmp/get_ipv4_address_menua.log /tmp/get_ipv4_address_menualist.log > /tmp/get_ipv4_address_menua_ip.log"
   SETAIP=$(cat /tmp/get_ipv4_address_menua_ip.log | awk '{print $2}')
   dialog --menu "IP function:" 10 10 10 1 new 2 alias 2>$GETIPV4MENUAIPFUNC
   GETIPV4MENUAIPFUNCN=$(cat $GETIPV4MENUAIPFUNC | sed 's/#//g' | sed 's/%//g')
   if [ $GETIPV4MENUCIPFUNCN = 1 ]; then
#      ###
#      ###
#      ###
#      ###
      ip addr flush dev $GETIPV4IFVALUE
      ip addr add $SETAIP/24 dev $GETIPV4IFVALUE
   else
      ip addr add $SETAIP/24 dev $GETIPV4IFVALUE
   fi
### ### ### ### ### ### ### ### ###
NEWAIP=$(ip addr show $GETIPV4IFVALUE | grep --color $SETAIP)
echo ""
ip addr show $GETIPV4IFVALUE
echo ""
echo "Your new IP: $NEWAIP"
### ### ### ### ### ### ### ### ###
# <// --- --- --- --- --- --- --- --- ---
      fi
### ###
   else
      echo 'looks like ... class B network'
# <--- --- --- --- --- --- --- --- ---//
   CLASSBNET=$(cat $GETIPV4 | grep "172.16" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "0.0.0.0" | sort | uniq | head -n 1 | awk -F. '{print $1"."$2"."$3}' | xargs -L1 -I {} echo {}.0/24)
   # /usr/bin/arp-scan -I $GETIPV4IFVALUE $CLASSBNET
   /usr/bin/arp-scan -I $GETIPV4IFVALUE $CLASSBNET > $GETIPV4ARPDIG
   CLASSBPRE=$(cat $GETIPV4 | grep "172.16" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "0.0.0.0" | sort | uniq | head -n 1 | awk -F. '{print $1"."$2"."$3}')
   GETIPV4CURRB=$(cat $GETIPV4ARPDIG | grep "172.16" | awk '{print $1}' | sort)
   netb1=$CLASSBPRE; ib1=1; GETIPV4FULLB=`while [ $ib1 -lt 255 ]; do echo $netb1.$ib1; ib1=$(($ib1+1)); done`
   echo $GETIPV4CURRB > $GETIPV4CURRBLIST
   echo $GETIPV4FULLB > $GETIPV4FULLBLIST
   tr ' ' '\n' < $GETIPV4CURRBLIST > $GETIPV4CURRBLISTL
   tr ' ' '\n' < $GETIPV4FULLBLIST > $GETIPV4FULLBLISTL
   sort -n $GETIPV4CURRBLISTL $GETIPV4FULLBLISTL | uniq -u > $GETIPV4SORTBLISTL
   nl $GETIPV4SORTBLISTL | sed 's/ //g' > $GETIPV4MENUB
   dialog --menu "Choose one (free) IP:" 45 45 40 `cat $GETIPV4MENUB` 2>$GETIPV4MENUBLIST
   /usr/bin/zsh -c "join /tmp/get_ipv4_address_menub.log /tmp/get_ipv4_address_menublist.log > /tmp/get_ipv4_address_menub_ip.log"
   SETBIP=$(cat /tmp/get_ipv4_address_menub_ip.log | awk '{print $2}')
   dialog --menu "IP function:" 10 10 10 1 new 2 alias 2>$GETIPV4MENUBIPFUNC
   GETIPV4MENUBIPFUNCN=$(cat $GETIPV4MENUBIPFUNC | sed 's/#//g' | sed 's/%//g')
   if [ $GETIPV4MENUBIPFUNCN = 1 ]; then
#      ###
#      ###
#      ###
#      ###
      ip addr flush dev $GETIPV4IFVALUE
      ip addr add $SETBIP/24 dev $GETIPV4IFVALUE
   else   
      ip addr add $SETBIP/24 dev $GETIPV4IFVALUE
   fi
### ### ### ### ### ### ### ### ###
NEWBIP=$(ip addr show $GETIPV4IFVALUE | grep --color $SETBIP)
echo ""
ip addr show $GETIPV4IFVALUE
echo ""
echo "Your new IP: $NEWBIP"
### ### ### ### ### ### ### ### ###
# <// --- --- --- --- --- --- --- --- ---
   fi
###
else
   echo 'looks like ... class C network'
# <--- --- --- --- --- --- --- --- ---//
   CLASSCNET=$(cat $GETIPV4 | grep "192.168" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "0.0.0.0" | sort | uniq | head -n 1 | awk -F. '{print $1"."$2"."$3}' | xargs -L1 -I {} echo {}.0/24)
   # /usr/bin/arp-scan -I $GETIPV4IFVALUE $CLASSCNET
   /usr/bin/arp-scan -I $GETIPV4IFVALUE $CLASSCNET > $GETIPV4ARPDIG
   CLASSCPRE=$(cat $GETIPV4 | grep "192.168" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "0.0.0.0" | sort | uniq | head -n 1 | awk -F. '{print $1"."$2"."$3}')
   GETIPV4CURRC=$(cat $GETIPV4ARPDIG | grep "192.168" | awk '{print $1}' | sort)
   netc1=$CLASSCPRE; ic1=1; GETIPV4FULLC=`while [ $ic1 -lt 255 ]; do echo $netc1.$ic1; ic1=$(($ic1+1)); done`
   echo $GETIPV4CURRC > $GETIPV4CURRCLIST
   echo $GETIPV4FULLC > $GETIPV4FULLCLIST
   tr ' ' '\n' < $GETIPV4CURRCLIST > $GETIPV4CURRCLISTL
   tr ' ' '\n' < $GETIPV4FULLCLIST > $GETIPV4FULLCLISTL
   sort -n $GETIPV4CURRCLISTL $GETIPV4FULLCLISTL | uniq -u > $GETIPV4SORTCLISTL
   nl $GETIPV4SORTCLISTL | sed 's/ //g' > $GETIPV4MENUC
   dialog --menu "Choose one (free) IP:" 45 45 40 `cat $GETIPV4MENUC` 2>$GETIPV4MENUCLIST
   /usr/bin/zsh -c "join /tmp/get_ipv4_address_menuc.log /tmp/get_ipv4_address_menuclist.log > /tmp/get_ipv4_address_menuc_ip.log"
   SETCIP=$(cat /tmp/get_ipv4_address_menuc_ip.log | awk '{print $2}')
   dialog --menu "IP function:" 10 10 10 1 new 2 alias 2>$GETIPV4MENUCIPFUNC
   GETIPV4MENUCIPFUNCN=$(cat $GETIPV4MENUCIPFUNC | sed 's/#//g' | sed 's/%//g')
   if [ $GETIPV4MENUCIPFUNCN = 1 ]; then
#      ###
#      ###
#      ###
#      ###
      ip addr flush dev $GETIPV4IFVALUE
      ip addr add $SETCIP/24 dev $GETIPV4IFVALUE
   else
      ip addr add $SETCIP/24 dev $GETIPV4IFVALUE
   fi
### ### ### ### ### ### ### ### ###
NEWCIP=$(ip addr show $GETIPV4IFVALUE | grep --color $SETCIP)
echo ""
ip addr show $GETIPV4IFVALUE
echo ""
echo "Your new IP: $NEWCIP"
### ### ### ### ### ### ### ### ###
# <// --- --- --- --- --- --- --- --- ---
fi

### // stage7 ###

### stage8 // ###

# <--- --- --- --- ROUTER // --- --- --- ---//

   #echo ""
   #echo "<--- ROUTER tcpdump preview // --->"
   #echo ""
   #/usr/sbin/tcpdump -e -n -i $GETIPV4IFVALUE -c 55 | grep --color "OSPFv2"
   #echo ""
   #echo "<--- // ROUTER tcpdump preview --->"
   echo ""
   (/usr/sbin/tcpdump -e -n -i $GETIPV4IFVALUE -c 55 | grep --color "OSPFv2" | awk '{print $10}' | sort | uniq 2>&1 > $GETIPV4ROUTER) &&
   #echo ""

TCPDUMP2=10
(
while test $TCPDUMP2 != 110
do
echo $TCPDUMP2
echo "XXX"
echo "discovering local router: ($TCPDUMP2 percent)"   
echo "XXX"
#
TCPDUMP2=`expr $TCPDUMP2 + 10`
sleep 1
done
) | dialog --title "tcpdump - router discovery" --gauge "discover local router" 20 70 0





   nl $GETIPV4ROUTER | sed 's/ //g' > $GETIPV4ROUTERLIST
   dialog --menu "Choose one default Router:" 10 30 40 `cat $GETIPV4ROUTERLIST` 2>$GETIPV4ROUTERLISTMENU
   /usr/bin/zsh -c "join /tmp/get_ipv4_router_list.log /tmp/get_ipv4_router_list_menu.log > /tmp/get_ipv4_router_list_menu_choosed.log"
   SETROUTERIP=$(cat /tmp/get_ipv4_router_list_menu_choosed.log | awk '{print $2}')

   echo "<--- set default router // --->"
   route del default
   route add default gw $SETROUTERIP dev $GETIPV4IFVALUE
   echo "<--- // set default router --->"

# <--- --- --- --- // ROUTER --- --- --- ---//

### // stage8 ###

### stage9 // ###

# <--- --- --- --- DNS Resolver // --- --- --- ---//

   dialog --checklist "Select fancy Public DNS Resolver:" 30 75 12 \
      1 "46.4.163.36    (plitc-public-dns-a.de.plitc.eu / germany only)" off\
      2 "46.4.163.37    (plitc-public-dns-b.de.plitc.eu / germany only)" off\
      3 "46.4.163.38    (plitc-public-dns-c.de.plitc.eu / germany only)" off\
      4 "213.73.19.35   (dnscache.berlin.ccc.de)" on\
      5 "74.82.42.42    (ordns.he.net)" on\
      6 "208.67.222.222 (resolver1.opendns.com)" off\
      7 "208.67.220.220 (resolver2.opendns.com)" off\
      8 "8.8.8.8        (google-public-dns-a.google.com)" off\
      9 "8.8.4.4        (google-public-dns-b.google.com)" off\
       2>$GETIPV4DNSLIST

   echo "<--- prepare /etc/resolv.conf // --->"

cat << DNSEOF > /tmp/get_ipv4_resolv.conf
### ### ### GET_IPv4 // ### ### ###
#
DNSEOF

GETIPV4DNSLISTCHECK1=$(grep "1" $GETIPV4DNSLIST | sed 's/#//g' | sed 's/%//g')
if [ -z $GETIPV4DNSLISTCHECK1 ]; then
   echo "" # dummy
   else
   echo "nameserver 46.4.163.36     # (plitc-public-dns-a.de.plitc.eu / germany only)" >> /tmp/get_ipv4_resolv.conf
fi

GETIPV4DNSLISTCHECK2=$(grep "2" $GETIPV4DNSLIST | sed 's/#//g' | sed 's/%//g')
if [ -z $GETIPV4DNSLISTCHECK2 ]; then
   echo "" # dummy
   else
   echo "nameserver 46.4.163.37     # (plitc-public-dns-b.de.plitc.eu / germany only)" >> /tmp/get_ipv4_resolv.conf
fi

GETIPV4DNSLISTCHECK3=$(grep "3" $GETIPV4DNSLIST | sed 's/#//g' | sed 's/%//g')
if [ -z $GETIPV4DNSLISTCHECK3 ]; then
   echo "" # dummy
   else
   echo "nameserver 46.4.163.38     # (plitc-public-dns-c.de.plitc.eu / germany only)" >> /tmp/get_ipv4_resolv.conf
fi

GETIPV4DNSLISTCHECK4=$(grep "4" $GETIPV4DNSLIST | sed 's/#//g' | sed 's/%//g')
if [ -z $GETIPV4DNSLISTCHECK4 ]; then
   echo "" # dummy
   else
   echo "nameserver 213.73.91.35    # (dnscache.berlin.ccc.de)" >> /tmp/get_ipv4_resolv.conf
fi

GETIPV4DNSLISTCHECK5=$(grep "5" $GETIPV4DNSLIST | sed 's/#//g' | sed 's/%//g')
if [ -z $GETIPV4DNSLISTCHECK5 ]; then
   echo "" # dummy
   else
   echo "nameserver 74.82.42.42     # (ordns.he.net)" >> /tmp/get_ipv4_resolv.conf
fi

GETIPV4DNSLISTCHECK6=$(grep "6" $GETIPV4DNSLIST | sed 's/#//g' | sed 's/%//g')
if [ -z $GETIPV4DNSLISTCHECK6 ]; then
   echo "" # dummy
   else
   echo "nameserver 208.67.222.222  # (resolver1.opendns.com)" >> /tmp/get_ipv4_resolv.conf
fi

GETIPV4DNSLISTCHECK7=$(grep "7" $GETIPV4DNSLIST | sed 's/#//g' | sed 's/%//g')
if [ -z $GETIPV4DNSLISTCHECK7 ]; then
   echo "" # dummy
   else
   echo "nameserver 208.67.220.220  # (resolver2.opendns.com)" >> /tmp/get_ipv4_resolv.conf
fi

GETIPV4DNSLISTCHECK8=$(grep "8" $GETIPV4DNSLIST | sed 's/#//g' | sed 's/%//g')
if [ -z $GETIPV4DNSLISTCHECK8 ]; then
   echo "" # dummy
   else
   echo "nameserver 8.8.8.8         # (google-public-dns-a.google.com)" >> /tmp/get_ipv4_resolv.conf
fi

GETIPV4DNSLISTCHECK9=$(grep "9" $GETIPV4DNSLIST | sed 's/#//g' | sed 's/%//g')
if [ -z $GETIPV4DNSLISTCHECK9 ]; then
   echo "" # dummy
   else
   echo "nameserver 8.8.4.4         # (google-public-dns-b.google.com)" >> /tmp/get_ipv4_resolv.conf
fi

cat << DNSENDEOF >> /tmp/get_ipv4_resolv.conf
#
### ### ### // GET_IPv4 ### ### ###
# EOF
DNSENDEOF

chattr -i /etc/resolv.conf
cp -f /tmp/get_ipv4_resolv.conf /etc/resolv.conf

   echo "<--- // prepare /etc/resolv.conf --->"

# <--- --- --- --- // DNS Resolver --- --- --- ---//

### // stage9 ###

### stage10 // ###

# <--- --- --- --- INFO Box // --- --- --- ---//

#clear

GETIPV4INFO="/tmp/get_ipv4_info.log"

   echo "" > $GETIPV4INFO
   echo "<--- --- --- INTERFACE --- --- --->" >> $GETIPV4INFO
   echo "" >> $GETIPV4INFO
   ip addr show $GETIPV4IFVALUE >> $GETIPV4INFO
   echo "" >> $GETIPV4INFO
   echo "<--- --- --- Default v4 Gateway --- --- --->" >> $GETIPV4INFO
   echo "" >> $GETIPV4INFO
   netstat -rn -4 >> $GETIPV4INFO
   echo "" >> $GETIPV4INFO
   echo "<--- --- --- /etc/resolv.conf --- --- --->" >> $GETIPV4INFO
   echo "" >> $GETIPV4INFO
   cat /etc/resolv.conf >> $GETIPV4INFO
   echo "" >> $GETIPV4INFO

dialog --textbox "$GETIPV4INFO" 0 0

# <--- --- --- --- // INFO Box --- --- --- ---//

### // stage10 ###

### clean up 3 // ###
rm -rf /tmp/get_ipv4*
### // clean up 3 ###
#
### // stage7 ###
)
### // get_ipv4_address ###
#/ exit 0
;;
   1)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /bin/echo "ERROR: :("
      exit 1
;;
   255)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /bin/echo "[ESC] key pressed."
      exit 1
;;
esac
#/ exit 0
fi
### // stage4 ###
#
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
