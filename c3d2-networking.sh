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
#/ DEBIAN=$(uname -a | awk '{print $6}')
DEBIAN=$(cat /etc/os-release | grep "ID" | egrep -v "VERSION" | sed 's/ID=//g')
#/ DEBVERSION=$(cat /etc/debian_version | cut -c1)
DEBVERSION=$(cat /etc/os-release | grep "VERSION_ID" | sed 's/VERSION_ID=//g' | sed 's/"//g')
MYNAME=$(whoami)
### // stage0 ###

case "$1" in
'network')
### stage1 // ###
case $DEBIAN in
debian)
### stage2 // ###
PING=$(/usr/bin/which ping)
ARPING=$(/usr/bin/which arping)
ARPSCAN=$(/usr/bin/which arp-scan)
DIALOG=$(/usr/bin/which dialog)
#/ ZSH=$(/usr/bin/which zsh) # deprecated
IFCONFIG=$(/usr/bin/which ifconfig)
TCPDUMP=$(/usr/bin/which tcpdump)
VLAN=$(/usr/bin/dpkg -l | grep vlan | awk '{print $2}')
#/ NETMANAGER=$(/etc/init.d/network-manager status | grep enabled | awk '{print $4}' | sed 's/)//g')
C3D2CONFIG=$(cat /etc/network/interfaces | grep "c3d2-network-config-start" | awk '{print $4}')
#/ BACKUPDATE=$(date +%Y-%m-%d-%H%M%S)
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
if [ X"$C3D2CONFIG" = X"c3d2-network-config-start" ]; then
   echo "" # dummy
else
#/ ### backup // ###
#/ cp -pf /etc/network/interfaces /etc/network/interfaces_$BACKUPDATE
#/ cp -pf /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf_$BACKUPDATE
#/ ### // backup ###
#/ if [ X"$NETMANAGER" = X"enabled" ]; then
#/ echo "Well, your current Setup use an Network-Manager, we don't like it"
#/ echo "" # dummy
#/ echo "run   /etc/init.d/network-manager stop; update-rc.d network-manager remove; /etc/init.d/networking stop   manually"
#/ echo "" # dummy
#/ echo "ERROR: network-manager is enabled"
#/ sleep 1
#/ exit 1
#/ (
dialog --title "disable Network-Manager" --backtitle "disable Network-Manager" --yesno "well, your current setup use an network-manager, we don't like that, can we disable it ? (press ESC to skip)" 8 95
#
response1=$?
case $response1 in
   0)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /etc/init.d/network-manager stop
      update-rc.d network-manager remove
      pkill nm-applet
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
### ### ### c3d2-network-config-start // ### ### ###
#
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
#/ exit 0
;;
esac
#/ )
#/ fi
#/ else
#/   echo "" # dummy
fi
if [ -z $PING ]; then
   echo "<--- --- --->"
   echo "need ping (iputils-ping)"
   echo "<--- --- --->"
   apt-get update
   apt-get install iputils-ping
#/ cd -
   echo "<--- --- --->"
#/ else
#/ echo "" # dummy
fi
if [ -z $ARPING ]; then
   echo "<--- --- --->"
   echo "need arping"
   echo "<--- --- --->"
   apt-get update
   apt-get install arping
#/ cd -
   echo "<--- --- --->"
#/ else
#/ echo "" # dummy
fi
if [ -z $ARPSCAN ]; then
   echo "<--- --- --->"
   echo "need arp-scan"
   echo "<--- --- --->"
   apt-get update
   apt-get install arp-scan
#/ cd -
   echo "<--- --- --->"
#/ else
#/ echo "" # dummy
fi
if [ -z $DIALOG ]; then
   echo "<--- --- --->"
   echo "need dialog"
   echo "<--- --- --->"
   apt-get update
   apt-get install dialog
#/ cd -
   echo "<--- --- --->"
#/ else
#/ echo "" # dummy
fi
#/ if [ -z $ZSH ]; then          # deprecated
#/    echo "<--- --- --->"       # deprecated
#/    echo "need zsh shell"      # deprecated
#/    echo "<--- --- --->"       # deprecated
#/    apt-get install -y zsh     # deprecated
#/    cd -                       # deprecated
#/    echo "<--- --- --->"       # deprecated
#/ else                          # deprecated
#/ echo "" # dummy               # deprecated
#/ fi                            # deprecated
if [ -z $IFCONFIG ]; then
    echo "<--- --- --->"
    echo "need ifconfig"
    echo "<--- --- --->"
    apt-get update
    apt-get install ifconfig
#/  cd -
    echo "<--- --- --->"
#/ else
#/ echo "" # dummy
fi
if [ -z $TCPDUMP ]; then
    echo "<--- --- --->"
    echo "need tcpdump"
    echo "<--- --- --->"
    apt-get update
    apt-get install tcpdump
#/  cd -
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
    apt-get update
    apt-get install vlan
#/  cd -
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
        priority=20
        id_str="C3D2"
}
network={
        ssid="C3D2 5"
        key_mgmt=NONE
        priority=21
}
network={
        ssid="C3D2.swedbert"
        key_mgmt=NONE
        priority=19
}
# network={
#         ssid="C3D2.sixxsbert"
#         # psk=""
#         proto=RSN
#         key_mgmt=WPA-PSK
#         pairwise=CCMP
#         auth_alg=OPEN
#         priority=18
# }
network={
        ssid="C3D2.42bertl"
        key_mgmt=NONE
        priority=17
}
#
### public hotspots // ###
network={
        ssid="NZ@McD1"
        key_mgmt=NONE
        priority=15
}
### // public hotspots ###
#
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
### fix2 // ###
awk 'NR==FNR {h[$1] = $2; next} {print $1,$2,h[$1]}' /tmp/c3d2-networking_if_2.txt /tmp/c3d2-networking_if_3.txt | awk '{print $2}' > /tmp/c3d2-networking_if_4.txt
#/ /usr/bin/zsh -c "join /tmp/c3d2-networking_if_2.txt /tmp/c3d2-networking_if_3.txt > /tmp/c3d2-networking_if_4.txt"
### // fix2 ###
GETIF=$(cat /tmp/c3d2-networking_if_4.txt)
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
#
### ### ### // c3d2-network-config-end ### ### ###
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
IPV4DNSTEST="/tmp/c3d2-networking_ipv4dnstest1.txt"
IPV4DNSTESTNEW="/tmp/c3d2-networking_ipv4dnstest2.txt"
#/ IPV4DNSTESTVALUE="/tmp/c3d2-networking_ipv4dnstest3.txt"
touch $IPV4DNSTEST
/bin/chmod 0600 $IPV4DNSTEST
/bin/echo "dnscache.berlin.ccc.de" > $IPV4DNSTEST
dialog --title "IPv4 DNS Test" --backtitle "IPv4 DNS Test" --inputbox "Enter a domain for analysis: (for example dnscache.berlin.ccc.de/213.73.91.35)" 8 85 `cat $IPV4DNSTEST` 2>$IPV4DNSTESTNEW
IPV4DNSTESTVALUE=$(/bin/cat /tmp/c3d2-networking_ipv4dnstest2.txt | sed 's/#//g' | sed 's/%//g' | sed 's/ //g')
/bin/ping -q -c5 $IPV4DNSTESTVALUE > /dev/null
if [ $? -eq 0 ]
then
   dialog --title "IPv4 DNS Test" --backtitle "IPv4 DNS Test" --msgbox "It works!" 0 0
   /bin/rm -f /tmp/c3d2-networking_ipv4dnstest*
dialog --title "Network Check" --backtitle "Network Check" --yesno "it works you can cancel the script. if you need vlan go ahead" 5 70
response3=$?
case $response3 in
   0)
      /bin/echo "" # dummy
#/ exit 0
;;
   1)
      /bin/echo "" # dummy
      exit 0
;;
   255)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /bin/echo "[ESC] key pressed."
      exit 0
;;
esac
#/   exit 0
else
      dialog --title "IPv4 DNS Test" --backtitle "IPv4 DNS Test" --msgbox "ERROR: can't ping!" 0 0
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /bin/echo "ERROR: server isn't responsive"
      /bin/sleep 2
   /bin/rm -f /tmp/c3d2-networking_ipv4dnstest*
#/ exit 1
      dialog --title "IPv4 DNS Test results" --backtitle "IPv4 DNS Test results" --msgbox "ERROR: your DNS looks broken, please check your /etc/resolv.conf & /etc/nsswitch.conf" 5 90
IPV4IPTEST="/tmp/c3d2-networking_ipv4iptest1.txt"
IPV4IPTESTNEW="/tmp/c3d2-networking_ipv4iptest2.txt"
#/ IPV4IPTESTVALUE="/tmp/c3d2-networking_ipv4iptest3.txt"
touch $IPV4IPTEST
/bin/chmod 0600 $IPV4IPTEST
/bin/echo "213.73.91.35" > $IPV4IPTEST
dialog --title "IPv4 IP Test" --backtitle "IPv4 IP Test" --inputbox "Enter a IP for analysis: (for example 213.73.91.35/dnscache.berlin.ccc.de)" 8 85 `cat $IPV4IPTEST` 2>$IPV4IPTESTNEW
IPV4IPTESTVALUE=$(/bin/cat /tmp/c3d2-networking_ipv4iptest2.txt | sed 's/#//g' | sed 's/%//g' | sed 's/ //g')
/bin/ping -q -c5 $IPV4IPTESTVALUE > /dev/null
if [ $? -eq 0 ]
then
   dialog --title "IPv4 IP Test" --backtitle "IPv4 IP Test" --msgbox "It works!" 0 0
   /bin/rm -f /tmp/c3d2-networking_ipv4iptest*
#/ exit 0
else
   dialog --title "IPv4 IP Test" --backtitle "IPv4 IP Test" --msgbox "ERROR: can't ping!" 0 0
   /bin/echo "" # dummy
   /bin/echo "" # dummy
   /bin/echo "ERROR: server isn't responsive"
   /bin/sleep 2
   /bin/rm -f /tmp/c3d2-networking_ipv4iptest*
dialog --title "IPv4 is broken" --backtitle "IPv4 is broken" --msgbox "ERROR: sorry your dns & routing is totally broken :(" 5 60
#/ exit 1
fi
#/ /bin/rm -f /tmp/c3d2-networking_ipv4iptest*
fi
#/ /bin/rm -f /tmp/c3d2-networking_ipv4dnstest*
#
IPCHECK=$(ip a | grep "inet" | egrep -v "127.0.0.1" | awk '{print $2}' | head -n 1)
if [ -z "$IPCHECK" ]; then
   echo "" # FUU
else

dialog --title "get_ipv4_address (experimental)" --backtitle "get_ipv4_address (experimental)" --yesno "the next steps are experimental but we try" 5 48
response2=$?
case $response2 in
   0)
### get_ipv4_address // ###
(
### stage5 // ###
rm -rf /tmp/get_ipv4*
GETIPV4Z="/tmp/get_ipv4_address_z.log"
touch $GETIPV4Z
GETIPV4="/tmp/get_ipv4_address.log"
touch $GETIPV4
GETIPV4ROUTER="/tmp/get_ipv4_router.log"
touch $GETIPV4ROUTER
GETIPV4ROUTER2="/tmp/get_ipv4_router2.log"
touch $GETIPV4ROUTER2
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
### fix3 // ###
awk 'NR==FNR {h[$1] = $2; next} {print $1,$2,h[$1]}' /tmp/c3d2-networking_ifconfig5.txt /tmp/c3d2-networking_ifconfig4.txt | awk '{print $2}' > /tmp/c3d2-networking_ifconfig6.txt
#/ /usr/bin/zsh -c "join /tmp/c3d2-networking_ifconfig4.txt /tmp/c3d2-networking_ifconfig5.txt > /tmp/c3d2-networking_ifconfig6.txt"
### // fix3 ###
sleep 1
GETIPV4IFVALUE=$(cat /tmp/c3d2-networking_ifconfig6.txt)
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

### iw list // ###
if [ X"$GETIPV4IFVALUE" = X"wlan0" ]; then
#/ echo "" # dummy
#/ else
#/ /bin/cat /etc/wpa_supplicant/wpa_supplicant.conf | grep 'ssid' | egrep -v "#" | sed 's/"//g' | awk '{print $1,$2,$3,$4,$5}' > /tmp/get_ipv4_address_iwlist1.txt
#/ nl /tmp/get_ipv4_address_iwlist1.txt | awk '{print $1,$2,$3,$4,$5}' > /tmp/get_ipv4_address_iwlist2.txt
#/ GETIPV4IWLIST=$(cat /tmp/get_ipv4_address_iwlist2.txt)
/bin/cat /etc/wpa_supplicant/wpa_supplicant.conf | grep 'ssid' | egrep -v "#" | sed 's/ssid=//g' > /tmp/get_ipv4_address_iwlist1.txt
nl /tmp/get_ipv4_address_iwlist1.txt > /tmp/get_ipv4_address_iwlist2.txt
/bin/sed 's/$/ off/' /tmp/get_ipv4_address_iwlist2.txt > /tmp/get_ipv4_address_iwlist3.txt
/bin/sed '0,/$/s/off/on/' /tmp/get_ipv4_address_iwlist3.txt > /tmp/get_ipv4_address_iwlist4.txt
GETIPV4IWLIST="/tmp/get_ipv4_address_iwlist4.txt"
dialog --radiolist "Choose one of your configured wireless network:" 45 45 40 --file $GETIPV4IWLIST 2>/tmp/get_ipv4_address_iwlist5.txt
awk 'NR==FNR {h[$1] = $2; next} {print $1,$2,h[$1]}' /tmp/get_ipv4_address_iwlist4.txt /tmp/get_ipv4_address_iwlist5.txt | awk '{print $2}' | sed 's/"//g' > /tmp/get_ipv4_address_iwlist6.txt
### run // ###
#/ killall -q dhclient
#/ ip addr flush dev wlan0
#/ GETIPV4IWLISTIF=$(cat /tmp/get_ipv4_address_iwlist6.txt)
#/ iwconfig wlan0 essid "$GETIPV4IWLISTIF"
#/ ifconfig wlan0 down
#/ sleep 1
#/ ifconfig wlan0 up
#/ sleep 2
#
killall -q dhclient
killall -q wpa_supplicant
GETIPV4IWLISTIF=$(cat /tmp/get_ipv4_address_iwlist6.txt)
/sbin/ip addr flush dev wlan0
/usr/sbin/service wpa_supplicant start
#/ /sbin/ifconfig wlan0 down
#/ /sbin/ip addr flush dev wlan0
sleep 1
#/ /sbin/ifconfig wlan0 up
/bin/echo "" # dummy
/bin/echo "" # dummy
/bin/echo "Access Point: try to establish an association with $GETIPV4IWLISTIF"
/sbin/iw dev wlan0 connect -w "$GETIPV4IWLISTIF"
/bin/sleep 6
### // run ###
fi
### // iw list ###

   #/ echo "<--- tcpdump preview // --->"
   #/ echo ""
   #/ /usr/sbin/tcpdump -e -n -i $GETIPV4IFVALUE -c 25 | grep --color 0x0800
   #/ echo ""
   #/ echo "<--- // tcpdump preview --->"
   #/ echo ""
   #/ (/usr/sbin/tcpdump -e -n -i $GETIPV4IFVALUE -c 5 | grep "0x0800" | awk '{print $10}' 2>&1 > $GETIPV4) &&
   #/ (/usr/sbin/tcpdump -e -n -i $GETIPV4IFVALUE -c 5 | grep "0x0806" | awk '{print $12}' 2>&1 >> $GETIPV4) &&
   #/ echo ""

/bin/echo "" > $GETIPV4
/bin/echo "" > $GETIPV4Z

TCPDUMP1=10
(
while test $TCPDUMP1 != 105
do
echo $TCPDUMP1
echo "XXX"
echo "discovering the local network: ($TCPDUMP1 percent)"
echo "XXX"
### run // ###
   #/ /bin/echo "" > $GETIPV4
   #/ /bin/echo "" > $GETIPV4Z
   #/ ( (/usr/sbin/tcpdump -e -n -i $GETIPV4IFVALUE -c 5 | egrep "0x0800|0x0806") >> $GETIPV4 2>&1) &
( (/usr/sbin/tcpdump -e -n -i $GETIPV4IFVALUE -c 5) 2>&1 >> $GETIPV4Z) &
   #/ sleep 1
   #/ ( (/usr/sbin/tcpdump -e -n -i $GETIPV4IFVALUE -c 2 | grep "0x0806" | awk '{print $12}') >> $GETIPV4 2>&1) &&
   #/ /bin/cat $GETIPV4Z | egrep "0x0800|0x0806" >> $GETIPV4
### // run ###
TCPDUMP1=`expr $TCPDUMP1 + 5`
sleep 1
done
) | dialog --title "tcpdump - network discovery" --gauge "discover the local network" 20 70 0

/bin/cat $GETIPV4Z | egrep "0x0800|0x0806" > $GETIPV4
echo "" # dummy
echo "<--- --- --- --- --- --- --- --- --->"

CLASSCTEST=$(grep -F "192.168." $GETIPV4 | wc -l | sed 's/ //g')
CLASSBTEST=$(grep -F "172.16." $GETIPV4 | wc -l | sed 's/ //g')
CLASSATEST=$(grep -F "10." $GETIPV4 | wc -l | sed 's/ //g')
CLASSDN42ATEST=$(grep -F "172.22." $GETIPV4 | wc -l | sed 's/ //g')

if [ $CLASSCTEST = 0 ]; then
   echo "WARNING: can't find class C network, try again ..."
   echo "<--- --- --->"
###
   if [ $CLASSBTEST = 0 ]; then
      echo "WARNING: can't find class B network, try again ..."
      echo "<--- --- --->"
### ###
      if [ $CLASSATEST = 0 ]; then
         echo "WARNING: can't find class A network, try again ..."
         echo "<--- --- --->"
### ### ###
            echo 'WARNING: no RFC1918 networks found, try dn42 ...'
            # exit 1
            echo "<--- --- --->"
### ### ### DN42a // ### ### ###
               if [ $CLASSDN42ATEST = 0 ]; then
                  echo "ERROR: ... doesn't work ... the tcpdump lookup was probably too short, try again"
                  echo "<--- --- --- --- --- --- --- --- --->"
                  exit 1
### ### ### ### ### ###
               else
                  echo 'looks like ... DN42 A network'
# <--- --- --- --- --- --- --- --- ---//
   CLASSDN42ANET=$(cat $GETIPV4 | grep "172.22" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep "172.22" | egrep -v "0.0.0.0" | sort | uniq | head -n 1 | awk -F. '{print $1"."$2"."$3}' | xargs -L1 -I {} echo {}.0/24)
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
### fix // ###
sort /tmp/get_ipv4_address_menudn42a.log > /tmp/get_ipv4_address_menudn42a_fix.log
awk 'NR==FNR {h[$1] = $2; next} {print $1,$2,h[$1]}' /tmp/get_ipv4_address_menudn42a_fix.log /tmp/get_ipv4_address_menudn42alist.log | awk '{print $2}' > /tmp/get_ipv4_address_menudn42a_ip.log
### // fix ###
#/ /usr/bin/zsh -c "join --nocheck-order /tmp/get_ipv4_address_menudn42a_fix.log /tmp/get_ipv4_address_menudn42alist.log > /tmp/get_ipv4_address_menudn42a_ip.log"
   SETDN42AIP=$(cat /tmp/get_ipv4_address_menudn42a_ip.log)
   dialog --menu "IP function:" 10 10 10 1 new 2 alias 2>$GETIPV4MENUDN42AIPFUNC
   GETIPV4MENUDN42AIPFUNCN=$(cat $GETIPV4MENUDN42AIPFUNC | sed 's/#//g' | sed 's/%//g')
   if [ $GETIPV4MENUDN42AIPFUNCN = 1 ]; then
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
sleep 4
### ### ### ### ### ### ### ### ###
# <// --- --- --- --- --- --- --- --- ---
#
### ### ### // DN42a ### ### ###
               fi
### ### ###
      else
         echo 'looks like ... class A network'
# <--- --- --- --- --- --- --- --- ---//
   CLASSANET=$(cat $GETIPV4 | grep "10." | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep "10." | egrep -v "0.0.0.0" | sort | uniq | head -n 1 | awk -F. '{print $1"."$2"."$3}' | xargs -L1 -I {} echo {}.0/24)
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
### fix // ###
sort /tmp/get_ipv4_address_menua.log > /tmp/get_ipv4_address_menua_fix.log
awk 'NR==FNR {h[$1] = $2; next} {print $1,$2,h[$1]}' /tmp/get_ipv4_address_menua_fix.log /tmp/get_ipv4_address_menualist.log | awk '{print $2}' > /tmp/get_ipv4_address_menua_ip.log
### // fix ###
#/ /usr/bin/zsh -c "join --nocheck-order /tmp/get_ipv4_address_menua_fix.log /tmp/get_ipv4_address_menualist.log > /tmp/get_ipv4_address_menua_ip.log"
   SETAIP=$(cat /tmp/get_ipv4_address_menua_ip.log)
   dialog --menu "IP function:" 10 10 10 1 new 2 alias 2>$GETIPV4MENUAIPFUNC
   GETIPV4MENUAIPFUNCN=$(cat $GETIPV4MENUAIPFUNC | sed 's/#//g' | sed 's/%//g')
   if [ $GETIPV4MENUCIPFUNCN = 1 ]; then
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
sleep 4
### ### ### ### ### ### ### ### ###
# <// --- --- --- --- --- --- --- --- ---
      fi
### ###
   else
      echo 'looks like ... class B network'
# <--- --- --- --- --- --- --- --- ---//
   CLASSBNET=$(cat $GETIPV4 | grep "172.16" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep "172.16" | egrep -v "0.0.0.0" | sort | uniq | head -n 1 | awk -F. '{print $1"."$2"."$3}' | xargs -L1 -I {} echo {}.0/24)
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
### fix // ###
sort /tmp/get_ipv4_address_menub.log > /tmp/get_ipv4_address_menub_fix.log
awk 'NR==FNR {h[$1] = $2; next} {print $1,$2,h[$1]}' /tmp/get_ipv4_address_menub_fix.log /tmp/get_ipv4_address_menublist.log | awk '{print $2}' > /tmp/get_ipv4_address_menub_ip.log
### // fix ###
#/ /usr/bin/zsh -c "join --nocheck-order /tmp/get_ipv4_address_menub_fix.log /tmp/get_ipv4_address_menublist.log > /tmp/get_ipv4_address_menub_ip.log"
   SETBIP=$(cat /tmp/get_ipv4_address_menub_ip.log)
   dialog --menu "IP function:" 10 10 10 1 new 2 alias 2>$GETIPV4MENUBIPFUNC
   GETIPV4MENUBIPFUNCN=$(cat $GETIPV4MENUBIPFUNC | sed 's/#//g' | sed 's/%//g')
   if [ $GETIPV4MENUBIPFUNCN = 1 ]; then
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
sleep 4
### ### ### ### ### ### ### ### ###
# <// --- --- --- --- --- --- --- --- ---
   fi
###
else
   echo 'looks like ... class C network'
# <--- --- --- --- --- --- --- --- ---//
   CLASSCNET=$(cat $GETIPV4 | grep "192.168" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep "192.168" | egrep -v "0.0.0.0" | sort | uniq | head -n 1 | awk -F. '{print $1"."$2"."$3}' | xargs -L1 -I {} echo {}.0/24)
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
### fix // ###
sort /tmp/get_ipv4_address_menuc.log > /tmp/get_ipv4_address_menuc_fix.log
awk 'NR==FNR {h[$1] = $2; next} {print $1,$2,h[$1]}' /tmp/get_ipv4_address_menuc_fix.log /tmp/get_ipv4_address_menuclist.log | awk '{print $2}' > /tmp/get_ipv4_address_menuc_ip.log
### // fix ###
#/ /usr/bin/zsh -c "join --nocheck-order /tmp/get_ipv4_address_menuc_fix.log /tmp/get_ipv4_address_menuclist.log > /tmp/get_ipv4_address_menuc_ip.log"
   SETCIP=$(cat /tmp/get_ipv4_address_menuc_ip.log)
   dialog --menu "IP function:" 10 10 10 1 new 2 alias 2>$GETIPV4MENUCIPFUNC
   GETIPV4MENUCIPFUNCN=$(cat $GETIPV4MENUCIPFUNC | sed 's/#//g' | sed 's/%//g')
   if [ $GETIPV4MENUCIPFUNCN = 1 ]; then
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
sleep 4
### ### ### ### ### ### ### ### ###
# <// --- --- --- --- --- --- --- --- ---
fi

### // stage7 ###

### stage8 // ###

# <--- --- --- --- ROUTER // --- --- --- ---//

   #/ echo ""
   #/ echo "<--- ROUTER tcpdump preview // --->"
   #/ echo ""
   #/ /usr/sbin/tcpdump -e -n -i $GETIPV4IFVALUE -c 55 | grep --color "OSPFv2"
   #/ echo ""
   #/ echo "<--- // ROUTER tcpdump preview --->"
   #/ echo ""
   #/ (/usr/sbin/tcpdump -e -n -i $GETIPV4IFVALUE -c 55 | grep --color "OSPFv2" | awk '{print $10}' | sort | uniq 2>&1 > $GETIPV4ROUTER) &&
   #/ echo ""

/bin/echo "" > $GETIPV4ROUTER

TCPDUMP2=10
(
while test $TCPDUMP2 != 105
do
echo $TCPDUMP2
echo "XXX"
echo "discovering local router: ($TCPDUMP2 percent)"   
echo "XXX"
### run // ###
   #/ /bin/echo "" > $GETIPV4ROUTER
( (/usr/sbin/tcpdump -e -n -i $GETIPV4IFVALUE -c 5) 2>&1 >> $GETIPV4ROUTER) &
   #/ /bin/cat $GETIPV4ROUTER | grep --color "OSPFv2" | awk '{print $10}' | sort | uniq > $GETIPV4ROUTER2
### // run ###
TCPDUMP2=`expr $TCPDUMP2 + 5`
sleep 1
done
) | dialog --title "tcpdump - router discovery" --gauge "discover local router" 20 70 0
   /bin/cat $GETIPV4ROUTER | grep --color "OSPFv2" | awk '{print $10}' | sort | uniq > $GETIPV4ROUTER2
   nl $GETIPV4ROUTER2 | sed 's/ //g' > $GETIPV4ROUTERLIST
   dialog --menu "Choose one default Router:" 10 30 40 `cat $GETIPV4ROUTERLIST` 2>$GETIPV4ROUTERLISTMENU
### fix4 // ###
awk 'NR==FNR {h[$1] = $2; next} {print $1,$2,h[$1]}' /tmp/get_ipv4_router_list.log /tmp/get_ipv4_router_list_menu.log > /tmp/get_ipv4_router_list_menu_choosed.log
#/   /usr/bin/zsh -c "join /tmp/get_ipv4_router_list.log /tmp/get_ipv4_router_list_menu.log > /tmp/get_ipv4_router_list_menu_choosed.log"
### // fix4 ###
   SETROUTERIP=$(cat /tmp/get_ipv4_router_list_menu_choosed.log | awk '{print $2}')
if [ -z $SETROUTERIP ]; then
   SETROUTERIPNEW="/tmp/get_ipv4_router_new.txt"
   dialog --title "Default Router IP" --backtitle "Default Router IP" --inputbox "We can't find a valid router with sniffing OSPF, enter the ip manually" 5 75 2>$SETROUTERIPNEW
   SETROUTERIPNEWVALUE=$(cat /tmp/get_ipv4_router_new.txt)
   echo "<--- set default router // --->"
   route del default
   route add default gw $SETROUTERIPNEWVALUE dev $GETIPV4IFVALUE
   echo "<--- // set default router --->"
else
   echo "<--- set default router // --->"
   route del default
   route add default gw $SETROUTERIP dev $GETIPV4IFVALUE
   echo "<--- // set default router --->"
fi

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

#/ clear

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
      /bin/echo "Have a nice day"
      exit 0
;;
   255)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /bin/echo "[ESC] key pressed."
      exit 0
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
;;
'hq-storage')
### stage1 // ###
#
case $DEBIAN in
debian)
### stage2 // ###
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
#
### stage4 // ###
rm -f /tmp/c3d2-networking_storage*
dialog --title "HQ Storage Server" --backtitle "HQ Storage Server" --radiolist "Choose one of your favorite Protocol:" 15 75 12 \
   1 "smb        (Server Message Block)" on\
   2 "nfs        (Network File System)" off\
   3 "webdav     (Web-based Distributed Authoring and Versioning)" off\
   4 "sshfs      (Secure Shell Filesystem)" off\
   5 "ftps       (Secure File Transfer Protocol)" off\
    2>/tmp/c3d2-networking_storage_1.txt
storage1=$?
case $storage1 in
   0)
      /bin/echo "" # dummy
cat /tmp/c3d2-networking_storage_1.txt | cut -c1 > /tmp/c3d2-networking_storage_2.txt
STORAGEPROTO=$(cat /tmp/c3d2-networking_storage_2.txt)
#
### // samba //
if [ X"$STORAGEPROTO" = X"1" ]; then
   #/ /bin/echo "" # dummy
STORAGESMB=$(dpkg -l | grep cifs-utils | awk '{print $2}')
if [ -z $STORAGESMB ]; then
   echo "<--- --- --->"
   echo "need cifs-utils (but disable samba daemon)"
   echo "<--- --- --->"
   sleep 2
   apt-get update
   sleep 2
   apt-get install cifs-utils
   sleep 2
   #/ apt-get remove -y samba
   systemctl stop smbd
   systemctl stop nmbd
   systemctl disable smbd
   systemctl disable nmbd
   #/ cd -
   echo "<--- --- --->"
   #/ else
   #/ echo "" # dummy
fi
ifconfig | grep 'Link' | awk '{print $1}' | egrep -v "lo" > /tmp/c3d2-networking_storage_if_1.txt
nl /tmp/c3d2-networking_storage_if_1.txt > /tmp/c3d2-networking_storage_if_2.txt
/bin/sed 's/$/ off/' /tmp/c3d2-networking_storage_if_2.txt > /tmp/c3d2-networking_storage_if_3.txt
/bin/sed '0,/$/s/off/on/' /tmp/c3d2-networking_storage_if_3.txt > /tmp/c3d2-networking_storage_if_4.txt
STORAGESMBSRVIF="/tmp/c3d2-networking_storage_if_4.txt"
dialog --title "HQ Storage Server mount Interface" --backtitle "HQ Storage Server mount Interface" --radiolist "Choose one of your active interface for mounting the storage:" 15 65 40 --file $STORAGESMBSRVIF 2>/tmp/c3d2-networking_storage_if_5.txt
storagesmb1=$?
case $storagesmb1 in
   0)
awk 'NR==FNR {h[$1] = $2; next} {print $1,$2,h[$1]}' /tmp/c3d2-networking_storage_if_4.txt /tmp/c3d2-networking_storage_if_5.txt | awk '{print $2}' | sed 's/"//g' > /tmp/c3d2-networking_storage_if_6.txt
STORAGESMBSRVIFCHOOSE=$(cat /tmp/c3d2-networking_storage_if_6.txt)
ip addr show $STORAGESMBSRVIFCHOOSE | grep "inet" | head -n 1 | awk '{print $2}' | sed 's/\/24//g' | awk -F. '{print $1"."$2"."$3}' > /tmp/c3d2-networking_storage_smb_ip1.txt
STORAGESMBSRVIFIP=$(cat /tmp/c3d2-networking_storage_smb_ip1.txt)
if [ -z $STORAGESMBSRVIFIP ]; then
   echo "" # dummy
   echo "" # dummy
   echo "ERROR: can't catch the interface ipv4 address"
   exit 1
fi
#
   #/ echo "" # dummy
   #/ echo "" # dummy
   #/ echo "<--- --- --->"
   #/ echo "set static ipv4 route to the storage server"
   #/ echo "<--- --- --->"
   #/ route del -host $STORAGESMBSRVIFIP.10 > /dev/null 2>&1
   #/ route add -host $STORAGESMBSRVIFIP.10 dev $STORAGESMBSRVIFCHOOSE
   #/ sleep 2
#
#/ STORAGESMBSRV=$STORAGESMBSRVIFIP.10
STORAGESMBSRVPORT=445
STORAGESMBSRVTIMEOUT=1
#
if nc -w $STORAGESMBSRVTIMEOUT -t $STORAGESMBSRVIFIP.10 $STORAGESMBSRVPORT; then
   echo "" # dummy
   echo "" # dummy
   echo "INFO: I was able to connect to $STORAGESMBSRVIFIP.10:${STORAGESMBSRVPORT}"
   sleep 2
   #/ echo "" # dummy
   #/ echo "<--- --- --->"
   #/ echo "try to mount the storage"
   #/ echo "<--- --- --->"
   echo "" # dummy
   mkdir -p /c3d2-storage
STORAGESMBSRVSTATUS=$(mount | grep /rpool | wc -l) #todo: test also for fusermount way of mounting -> ${c3d2-storage-localmountpath}
if [ X"$STORAGESMBSRVSTATUS" = X"1" ]; then
   #/ echo "" # dummy
   echo "ERROR: storage is already mounted"
   sleep 2
   #/ exit 1
###
dialog --title "HQ Storage Server - umount" --backtitle "HQ Storage Server - umount" --yesno "Do you want umount the current storage? (press ESC to skip)" 5 66
storagesmb2=$?
case $storagesmb2 in
   0)
      umount /c3d2-storage
;;
   1)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      #/ /bin/echo "ERROR:"
      exit 0
;;
   255)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /bin/echo "[ESC] key pressed."
      exit 0
;;
esac
###
else
   mount -t cifs //$STORAGESMBSRVIFIP.10/rpool /c3d2-storage -o user=k-ot
   echo "" # dummy
   df -h
fi
else
   echo "" # dummy
   echo "" # dummy
   echo "ERROR: Connection to $STORAGESMBSRVIFIP.10:${STORAGESMBSRVPORT} failed"
   exit 1
fi
#
;;
   1)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      #/ /bin/echo "ERROR:"
      exit 0
;;
   255)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /bin/echo "[ESC] key pressed."
      exit 0
;;
esac
fi
rm -f /tmp/c3d2-networking_storage*
#
### // nfs //
if [ X"$STORAGEPROTO" = X"2" ]; then
      /bin/echo "" # dummy
STORAGENFS=$(dpkg -l | grep nfs-common | awk '{print $2}')
if [ -z $STORAGENFS ]; then
   echo "<--- --- --->"
   echo "need nfs-common/portmap"
   echo "<--- --- --->"
   sleep 2
   apt-get update
   sleep 2
   apt-get install nfs-common portmap
   sleep 2
   #
   #/ cd -
   echo "<--- --- --->"
   #/ else
   #/ echo "" # dummy
fi
ifconfig | grep 'Link' | awk '{print $1}' | egrep -v "lo" > /tmp/c3d2-networking_storage_if_1.txt
nl /tmp/c3d2-networking_storage_if_1.txt > /tmp/c3d2-networking_storage_if_2.txt
/bin/sed 's/$/ off/' /tmp/c3d2-networking_storage_if_2.txt > /tmp/c3d2-networking_storage_if_3.txt
/bin/sed '0,/$/s/off/on/' /tmp/c3d2-networking_storage_if_3.txt > /tmp/c3d2-networking_storage_if_4.txt
STORAGENFSSRVIF="/tmp/c3d2-networking_storage_if_4.txt"
dialog --title "HQ Storage Server mount Interface" --backtitle "HQ Storage Server mount Interface" --radiolist "Choose one of your active interface for mounting the storage:" 15 65 40 --file $STORAGENFSSRVIF 2>/tmp/c3d2-networking_storage_if_5.txt
storagenfs1=$?
case $storagenfs1 in
   0)
awk 'NR==FNR {h[$1] = $2; next} {print $1,$2,h[$1]}' /tmp/c3d2-networking_storage_if_4.txt /tmp/c3d2-networking_storage_if_5.txt | awk '{print $2}' | sed 's/"//g' > /tmp/c3d2-networking_storage_if_6.txt
STORAGENFSSRVIFCHOOSE=$(cat /tmp/c3d2-networking_storage_if_6.txt)
ip addr show $STORAGENFSSRVIFCHOOSE | grep "inet" | head -n 1 | awk '{print $2}' | sed 's/\/24//g' | awk -F. '{print $1"."$2"."$3}' > /tmp/c3d2-networking_storage_nfs_ip1.txt
STORAGENFSSRVIFIP=$(cat /tmp/c3d2-networking_storage_nfs_ip1.txt)
if [ -z $STORAGENFSSRVIFIP ]; then
   echo "" # dummy
   echo "" # dummy
   echo "ERROR: can't catch the interface ipv4 address"
   exit 1
fi
#
   #/ echo "" # dummy
   #/ echo "" # dummy
   #/ echo "<--- --- --->"
   #/ echo "set static ipv4 route to the storage server"
   #/ echo "<--- --- --->"
   #/ route del -host $STORAGENFSSRVIFIP.10 > /dev/null 2>&1
   #/ route add -host $STORAGENFSSRVIFIP.10 dev $STORAGENFSSRVIFCHOOSE
   #/ sleep 2
#
#/ STORAGENFSSRV=$STORAGENFSSRVIFIP.10
STORAGENFSSRVPORT=2049
STORAGENFSSRVTIMEOUT=1
#
if nc -w $STORAGENFSSRVTIMEOUT -t $STORAGENFSSRVIFIP.10 $STORAGENFSSRVPORT; then
   echo "" # dummy
   echo "" # dummy
   echo "INFO: I was able to connect to $STORAGENFSSRVIFIP.10:${STORAGENFSSRVPORT}"
   sleep 2
   #/ echo "" # dummy
   #/ echo "<--- --- --->"
   #/ echo "try to mount the storage"
   #/ echo "<--- --- --->"
   echo "" # dummy
   mkdir -p /c3d2-storage
STORAGENFSSRVSTATUS=$(mount | grep "rpool" | wc -l)
if [ X"$STORAGENFSSRVSTATUS" = X"1" ]; then
   #/ echo "" # dummy
   echo "ERROR: storage is already mounted"
   sleep 2
   #/ exit 1
###
dialog --title "HQ Storage Server - umount" --backtitle "HQ Storage Server - umount" --yesno "Do you want umount the current storage? (press ESC to skip)" 5 66
storagenfs2=$?
case $storagenfs2 in
   0)
      umount /c3d2-storage
;;
   1)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      #/ /bin/echo "ERROR:"
      exit 0
;;
   255)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /bin/echo "[ESC] key pressed."
      exit 0
;;
esac
###
else
   mount -t nfs $STORAGENFSSRVIFIP.10:/mnt/zroot/storage/rpool /c3d2-storage -o soft,timeo=15,noatime
   echo "" # dummy
   df -h
fi
else
   echo "" # dummy
   echo "" # dummy
   echo "ERROR: Connection to $STORAGENFSSRVIFIP.10:${STORAGENFSSRVPORT} failed"
   exit 1
fi
#
;;
   1)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      #/ /bin/echo "ERROR:"
      exit 0
;;
   255)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /bin/echo "[ESC] key pressed."
      exit 0
;;
esac
fi
rm -f /tmp/c3d2-networking_storage*
#
### // webdav //
if [ X"$STORAGEPROTO" = X"3" ]; then
      /bin/echo "" # dummy
STORAGEWEB=$(dpkg -l | grep davfs2 | awk '{print $2}')
if [ -z $STORAGEWEB ]; then
   echo "<--- --- --->"
   echo "need davfs2"
   echo "<--- --- --->"
   sleep 2
   apt-get update
   sleep 2
   apt-get install davfs2
   sleep 2
   #
   #/ cd -
   echo "<--- --- --->"
   #/ else
   #/ echo "" # dummy
fi
ifconfig | grep 'Link' | awk '{print $1}' | egrep -v "lo" > /tmp/c3d2-networking_storage_if_1.txt
nl /tmp/c3d2-networking_storage_if_1.txt > /tmp/c3d2-networking_storage_if_2.txt
/bin/sed 's/$/ off/' /tmp/c3d2-networking_storage_if_2.txt > /tmp/c3d2-networking_storage_if_3.txt
/bin/sed '0,/$/s/off/on/' /tmp/c3d2-networking_storage_if_3.txt > /tmp/c3d2-networking_storage_if_4.txt
STORAGEWEBSRVIF="/tmp/c3d2-networking_storage_if_4.txt"
dialog --title "HQ Storage Server mount Interface" --backtitle "HQ Storage Server mount Interface" --radiolist "Choose one of your active interface for mounting the storage:" 15 65 40 --file $STORAGEWEBSRVIF 2>/tmp/c3d2-networking_storage_if_5.txt
storageweb1=$?
case $storageweb1 in
   0)
awk 'NR==FNR {h[$1] = $2; next} {print $1,$2,h[$1]}' /tmp/c3d2-networking_storage_if_4.txt /tmp/c3d2-networking_storage_if_5.txt | awk '{print $2}' | sed 's/"//g' > /tmp/c3d2-networking_storage_if_6.txt
STORAGEWEBSRVIFCHOOSE=$(cat /tmp/c3d2-networking_storage_if_6.txt)
ip addr show $STORAGEWEBSRVIFCHOOSE | grep "inet" | head -n 1 | awk '{print $2}' | sed 's/\/24//g' | awk -F. '{print $1"."$2"."$3}' > /tmp/c3d2-networking_storage_web_ip1.txt
STORAGEWEBSRVIFIP=$(cat /tmp/c3d2-networking_storage_web_ip1.txt)
if [ -z $STORAGEWEBSRVIFIP ]; then
   echo "" # dummy
   echo "" # dummy
   echo "ERROR: can't catch the interface ipv4 address"
   exit 1
fi
#
   #/ echo "" # dummy
   #/ echo "" # dummy
   #/ echo "<--- --- --->"
   #/ echo "set static ipv4 route to the storage server"
   #/ echo "<--- --- --->"
   #/ route del -host $STORAGEWEBSRVIFIP.10 > /dev/null 2>&1
   #/ route add -host $STORAGEWEBSRVIFIP.10 dev $STORAGEWEBSRVIFCHOOSE
   #/ sleep 2
#
#/ STORAGEWEBSRV=$STORAGEWEBSRVIFIP.10
STORAGEWEBSRVPORT=8080
STORAGEWEBSRVTIMEOUT=1
#
if nc -w $STORAGEWEBSRVTIMEOUT -t $STORAGEWEBSRVIFIP.10 $STORAGEWEBSRVPORT; then
   echo "" # dummy
   echo "" # dummy
   echo "INFO: I was able to connect to $STORAGEWEBSRVIFIP.10:${STORAGEWEBSRVPORT}"
   sleep 2
   #/ echo "" # dummy
   #/ echo "<--- --- --->"
   #/ echo "try to mount the storage"
   #/ echo "<--- --- --->"
   echo "" # dummy
   mkdir -p /c3d2-storage
STORAGEWEBSRVSTATUS=$(mount | grep "rpool" | wc -l)
if [ X"$STORAGEWEBSRVSTATUS" = X"1" ]; then
   #/ echo "" # dummy
   echo "ERROR: storage is already mounted"
   sleep 2
   #/ exit 1
###
dialog --title "HQ Storage Server - umount" --backtitle "HQ Storage Server - umount" --yesno "Do you want umount the current storage? (press ESC to skip)" 5 66
storageweb2=$?
case $storageweb2 in
   0)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      umount /c3d2-storage
;;
   1)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      #/ /bin/echo "ERROR:"
      exit 0
;;
   255)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /bin/echo "[ESC] key pressed."
      exit 0
;;
esac
###
else
   mount -t davfs -o username=webdav http://$STORAGEWEBSRVIFIP.10:8080/rpool /c3d2-storage
   echo "" # dummy
   df -h
fi
else
   echo "" # dummy
   echo "" # dummy
   echo "ERROR: Connection to $STORAGEWEBSRVIFIP.10:${STORAGEWEBSRVPORT} failed"
   exit 1
fi
#
;;
   1)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      #/ /bin/echo "ERROR:"
      exit 0
;;
   255)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /bin/echo "[ESC] key pressed."
      exit 0
;;
esac
fi
rm -f /tmp/c3d2-networking_storage*
#
### // sshfs //
if [ X"$STORAGEPROTO" = X"4" ]; then
      /bin/echo "" # dummy
STORAGESSHFS=$(dpkg -l | grep sshfs | awk '{print $2}')
if [ -z $STORAGESSHFS ]; then
   echo "<--- --- --->"
   echo "need sshfs"
   echo "<--- --- --->"
   sleep 2
   apt-get update
   sleep 2
   apt-get install sshfs
   sleep 2
   #
   #/ cd -
   echo "<--- --- --->"
   #/ else
   #/ echo "" # dummy
fi
ifconfig | grep 'Link' | awk '{print $1}' | egrep -v "lo" > /tmp/c3d2-networking_storage_if_1.txt
nl /tmp/c3d2-networking_storage_if_1.txt > /tmp/c3d2-networking_storage_if_2.txt
/bin/sed 's/$/ off/' /tmp/c3d2-networking_storage_if_2.txt > /tmp/c3d2-networking_storage_if_3.txt
/bin/sed '0,/$/s/off/on/' /tmp/c3d2-networking_storage_if_3.txt > /tmp/c3d2-networking_storage_if_4.txt
STORAGESSHFSSRVIF="/tmp/c3d2-networking_storage_if_4.txt"
dialog --title "HQ Storage Server mount Interface" --backtitle "HQ Storage Server mount Interface" --radiolist "Choose one of your active interface for mounting the storage:" 15 65 40 --file $STORAGESSHFSSRVIF 2>/tmp/c3d2-networking_storage_if_5.txt
storagesshfs1=$?
case $storagesshfs1 in
   0)
awk 'NR==FNR {h[$1] = $2; next} {print $1,$2,h[$1]}' /tmp/c3d2-networking_storage_if_4.txt /tmp/c3d2-networking_storage_if_5.txt | awk '{print $2}' | sed 's/"//g' > /tmp/c3d2-networking_storage_if_6.txt
STORAGESSHFSSRVIFCHOOSE=$(cat /tmp/c3d2-networking_storage_if_6.txt)
ip addr show $STORAGESSHFSSRVIFCHOOSE | grep "inet" | head -n 1 | awk '{print $2}' | sed 's/\/24//g' | awk -F. '{print $1"."$2"."$3}' > /tmp/c3d2-networking_storage_sshfs_ip1.txt
STORAGESSHFSSRVIFIP=$(cat /tmp/c3d2-networking_storage_sshfs_ip1.txt)
if [ -z $STORAGESSHFSSRVIFIP ]; then
   echo "" # dummy
   echo "" # dummy
   echo "ERROR: can't catch the interface ipv4 address"
   exit 1
fi
#
   #/ echo "" # dummy
   #/ echo "" # dummy
   #/ echo "<--- --- --->"
   #/ echo "set static ipv4 route to the storage server"
   #/ echo "<--- --- --->"
   #/ route del -host $STORAGESSHFSSRVIFIP.10 > /dev/null 2>&1
   #/ route add -host $STORAGESSHFSSRVIFIP.10 dev $STORAGESSHFSSRVIFCHOOSE
   #/ sleep 2
#
#/ STORAGESSHFSSRV=$STORAGESSHFSSRVIFIP.10
STORAGESSHFSSRVPORT=22
STORAGESSHFSSRVTIMEOUT=1
#
   echo "" # dummy
   echo "" # dummy
if nc -w $STORAGESSHFSSRVTIMEOUT -t $STORAGESSHFSSRVIFIP.10 $STORAGESSHFSSRVPORT; then
   echo "" # dummy
   echo "" # dummy
   echo "INFO: I was able to connect to $STORAGESSHFSSRVIFIP.10:${STORAGESSHFSSRVPORT}"
   sleep 2
   #/ echo "" # dummy
   #/ echo "<--- --- --->"
   #/ echo "try to mount the storage"
   #/ echo "<--- --- --->"
   echo "" # dummy
   mkdir -p /c3d2-storage
STORAGESSHFSSRVSTATUS=$(mount | grep "rpool" | wc -l)
if [ X"$STORAGESSHFSSRVSTATUS" = X"1" ]; then
   #/ echo "" # dummy
   echo "ERROR: storage is already mounted"
   sleep 2
   #/ exit 1
###
dialog --title "HQ Storage Server - umount" --backtitle "HQ Storage Server - umount" --yesno "Do you want umount the current storage? (press ESC to skip)" 5 66
storagesshfs2=$?
case $storagesshfs2 in
   0)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      umount /c3d2-storage
;;
   1)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      #/ /bin/echo "ERROR:"
      exit 0
;;
   255)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /bin/echo "[ESC] key pressed."
      exit 0
;;
esac
###
else
   sshfs root@$STORAGESSHFSSRVIFIP.10:/mnt/zroot/storage/rpool /c3d2-storage
   echo "" # dummy
   df -h
fi
else
   echo "" # dummy
   echo "" # dummy
   echo "ERROR: Connection to $STORAGESSHFSSRVIFIP.10:${STORAGESSHFSSRVPORT} failed"
   exit 1
fi
#
;;
   1)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      #/ /bin/echo "ERROR:"
      exit 0
;;
   255)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /bin/echo "[ESC] key pressed."
      exit 0
;;
esac
fi
rm -f /tmp/c3d2-networking_storage*
#
### // ftp //
if [ X"$STORAGEPROTO" = X"5" ]; then
      /bin/echo "" # dummy
STORAGEFTP=$(dpkg -l | grep curlftpfs | awk '{print $2}')
if [ -z $STORAGEFTP ]; then
   echo "<--- --- --->"
   echo "need curlftpfs"
   echo "<--- --- --->"
   sleep 2
   apt-get update
   sleep 2
   apt-get install curlftpfs
   sleep 2
   #
   #/ cd -
   echo "<--- --- --->"
   #/ else
   #/ echo "" # dummy
fi
ifconfig | grep 'Link' | awk '{print $1}' | egrep -v "lo" > /tmp/c3d2-networking_storage_if_1.txt
nl /tmp/c3d2-networking_storage_if_1.txt > /tmp/c3d2-networking_storage_if_2.txt
/bin/sed 's/$/ off/' /tmp/c3d2-networking_storage_if_2.txt > /tmp/c3d2-networking_storage_if_3.txt
/bin/sed '0,/$/s/off/on/' /tmp/c3d2-networking_storage_if_3.txt > /tmp/c3d2-networking_storage_if_4.txt
STORAGEFTPSRVIF="/tmp/c3d2-networking_storage_if_4.txt"
dialog --title "HQ Storage Server mount Interface" --backtitle "HQ Storage Server mount Interface" --radiolist "Choose one of your active interface for mounting the storage:" 15 65 40 --file $STORAGEFTPSRVIF 2>/tmp/c3d2-networking_storage_if_5.txt
storageftp1=$?
case $storageftp1 in
   0)
awk 'NR==FNR {h[$1] = $2; next} {print $1,$2,h[$1]}' /tmp/c3d2-networking_storage_if_4.txt /tmp/c3d2-networking_storage_if_5.txt | awk '{print $2}' | sed 's/"//g' > /tmp/c3d2-networking_storage_if_6.txt
STORAGEFTPSRVIFCHOOSE=$(cat /tmp/c3d2-networking_storage_if_6.txt)
ip addr show $STORAGEFTPSRVIFCHOOSE | grep "inet" | head -n 1 | awk '{print $2}' | sed 's/\/24//g' | awk -F. '{print $1"."$2"."$3}' > /tmp/c3d2-networking_storage_ftp_ip1.txt
STORAGEFTPSRVIFIP=$(cat /tmp/c3d2-networking_storage_ftp_ip1.txt)
if [ -z $STORAGEFTPSRVIFIP ]; then
   echo "" # dummy
   echo "" # dummy
   echo "ERROR: can't catch the interface ipv4 address"
   exit 1
fi
#
   #/ echo "" # dummy
   #/ echo "" # dummy
   #/ echo "<--- --- --->"
   #/ echo "set static ipv4 route to the storage server"
   #/ echo "<--- --- --->"
   #/ route del -host $STORAGEFTPSRVIFIP.10 > /dev/null 2>&1
   #/ route add -host $STORAGEFTPSRVIFIP.10 dev $STORAGEFTPSRVIFCHOOSE
   #/ sleep 2
#
#/ STORAGEFTPSRV=$STORAGEFTPSRVIFIP.10
STORAGEFTPSRVPORT=21
STORAGEFTPSRVTIMEOUT=1
#
   echo "" # dummy
   echo "" # dummy
if nc -u -w $STORAGEFTPSRVTIMEOUT -t $STORAGEFTPSRVIFIP.10 $STORAGEFTPSRVPORT; then
   echo "" # dummy
   echo "" # dummy
   echo "INFO: I was able to connect to $STORAGEFTPSRVIFIP.10:${STORAGEFTPSRVPORT}"
   sleep 2
   #/ echo "" # dummy
   #/ echo "<--- --- --->"
   #/ echo "try to mount the storage"
   #/ echo "<--- --- --->"
   echo "" # dummy
   mkdir -p /c3d2-storage
STORAGEFTPSRVSTATUS=$(mount | grep "curlftpfs" | wc -l) #todo: check for other mount-way to ${c3d2-storage-localmountpath}
if [ X"$STORAGEFTPSRVSTATUS" = X"1" ]; then
   #/ echo "" # dummy
   echo "ERROR: storage is already mounted"
   sleep 2
   #/ exit 1
###
dialog --title "HQ Storage Server - umount" --backtitle "HQ Storage Server - umount" --yesno "Do you want umount the current storage? (press ESC to skip)" 5 66
storageftp2=$?
case $storageftp2 in
   0)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      #/ umount /c3d2-storage
      fusermount -u /c3d2-storage #/; fusermount -u /c3d2-storage
;;
   1)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      #/ /bin/echo "ERROR:"
      exit 0
;;
   255)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /bin/echo "[ESC] key pressed."
      exit 0
;;
esac
###
else
rm -f /root/.netrc
touch /root/.netrc
chmod 0600 /root/.netrc
STORAGEFTPAUTHFILE=$(cat /root/.netrc)
 if [ -z $STORAGEFTPAUTHFILE ]; then
/bin/cat <<STORAGEFTPLOGIN > /root/.netrc
### ### ### c3d2-hq-storage // ### ### ###
#
machine $STORAGEFTPSRVIFIP.10
login k-ot
password
#
### ### ### // c3d2-hq-storage ### ### ###
# EOF
STORAGEFTPLOGIN
 fi
### password // ###
dialog --title "HQ Storage Server - ftps password" --backtitle "HQ Storage Server - ftps password" --clear --insecure --passwordbox "Enter your password" 10 60 2>> /root/.netrc
sed -i '/password/d' /root/.netrc
sed -i '$s/^/password /' /root/.netrc
### // password ###
   echo "" # dummy
   echo "" # dummy
   curlftpfs -o ssl,no_verify_hostname,no_verify_peer $STORAGEFTPSRVIFIP.10 /c3d2-storage
   echo "" # dummy
   df -h
fi
else
   echo "" # dummy
   echo "" # dummy
   echo "ERROR: Connection to $STORAGEFTPSRVIFIP.10:${STORAGEFTPSRVPORT} failed"
   exit 1
fi
#
;;
   1)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      #/ /bin/echo "ERROR:"
      exit 0
;;
   255)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /bin/echo "[ESC] key pressed."
      exit 0
;;
esac
fi
rm -f /tmp/c3d2-networking_storage*
#
;;
   1)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      #/ /bin/echo "ERROR:"
      exit 0
;;
   255)
      /bin/echo "" # dummy
      /bin/echo "" # dummy
      /bin/echo "[ESC] key pressed."
      exit 0
;;
esac
#
### // stage4 ###
#
### // stage3 ###
#
### // stage2 ###
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
;;
'hq-printer')
### stage1 // ###
#
case $DEBIAN in
debian)
### stage2 // ###


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


#
### // stage3 ###
#
### // stage2 ###
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
;;
'config-backup')
### stage1 // ###
#
case $DEBIAN in
debian)
### stage2 // ###
BACKUPDATE=$(date +%Y-%m-%d-%H%M%S)
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
### backup // ###
cp -pf /etc/network/interfaces /etc/network/interfaces_$BACKUPDATE
cp -pf /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf_$BACKUPDATE
### // backup ###
#
### // stage3 ###
#
### // stage2 ###
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
;;
*)
echo "usage: $0 { network | hq-storage | config-backup }"
;;
esac
exit 0

### ### ### PLITC ### ### ###
# EOF
