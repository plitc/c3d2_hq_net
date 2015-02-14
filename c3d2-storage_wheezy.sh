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
DEBIAN=$(grep "ID" /etc/os-release | egrep -v "VERSION" | sed 's/ID=//g')
DEBVERSION=$(grep "VERSION_ID" /etc/os-release | sed 's/VERSION_ID=//g' | sed 's/"//g')
MYNAME=$(whoami)
### // stage0 ###

case "$1" in
'hq-storage')
### stage1 // ###
#
case $DEBIAN in
debian)
### stage2 // ###
#
DIALOG=$(/usr/bin/which dialog)
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
if [ "$DEBVERSION" = "7" ]; then
   echo "" # dummy
else
   echo "<--- --- --->"
   echo ""
   echo "ERROR: You need Debian 7 (Wheezy) Version"
   exit 1
fi
#
if [ -z "$DIALOG" ]; then
   echo "<--- --- --->"
   echo "need dialog"
   echo "<--- --- --->"
   apt-get update
   apt-get install dialog
   echo "<--- --- --->"
fi
### stage4 // ###
rm -f /tmp/c3d2-networking_storage*
dialog --title "HQ Storage Servers" --backtitle "HQ Storage Servers" --radiolist "Choose one of your favorite Protocol:" 15 75 12 \
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
cut -c1 /tmp/c3d2-networking_storage_1.txt > /tmp/c3d2-networking_storage_2.txt
STORAGEPROTO=$(cat /tmp/c3d2-networking_storage_2.txt)
#
### // samba //
if [ X"$STORAGEPROTO" = X"1" ]; then
STORAGESMB=$(dpkg -l | grep cifs-utils | awk '{print $2}')
if [ -z "$STORAGESMB" ]; then
   echo "<--- --- --->"
   echo "need cifs-utils (but disable samba daemon)"
   echo "<--- --- --->"
   sleep 2
   apt-get update
   sleep 2
   apt-get install cifs-utils
   sleep 2
   #/ apt-get remove -y samba
   service smbd stop
   service nmbd stop
   service samba stop
   #
   update-rc.d smbd disable
   update-rc.d nmbd disable
   update-rc.d samba disable
   echo "<--- --- --->"
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
ip addr show "$STORAGESMBSRVIFCHOOSE" | grep "inet" | head -n 1 | awk '{print $2}' | sed 's/\/24//g' | awk -F. '{print $1"."$2"."$3}' > /tmp/c3d2-networking_storage_smb_ip1.txt
STORAGESMBSRVIFIP=$(cat /tmp/c3d2-networking_storage_smb_ip1.txt)
if [ -z "$STORAGESMBSRVIFIP" ]; then
   echo "" # dummy
   echo "" # dummy
   echo "ERROR: can't catch the interface ipv4 address"
   exit 1
fi
STORAGESMBSRVPORT=445
STORAGESMBSRVTIMEOUT=1

if nc -w $STORAGESMBSRVTIMEOUT -t "$STORAGESMBSRVIFIP".10 $STORAGESMBSRVPORT; then
   echo "" # dummy
   echo "" # dummy
   echo "INFO: I was able to connect to $STORAGESMBSRVIFIP.10:${STORAGESMBSRVPORT}"
   sleep 2
   echo "" # dummy
   mkdir -p /c3d2-storage
   mkdir -p /c3d2-storage-crypto
STORAGESMBSRVSTATUS=$(mount | grep -c "c3d2-storage")
if [ X"$STORAGESMBSRVSTATUS" = X"1" ]; then
   echo "ERROR: storage is already mounted"
   sleep 2
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
   mount -t cifs //"$STORAGESMBSRVIFIP".10/rpool /c3d2-storage -o user=k-ot
   mount -t cifs //"$STORAGESMBSRVIFIP".71/cpool /c3d2-storage-crypto -o user=k-ot
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
if [ -z "$STORAGENFS" ]; then
   echo "<--- --- --->"
   echo "need nfs-common/portmap"
   echo "<--- --- --->"
   sleep 2
   apt-get update
   sleep 2
   apt-get install nfs-common portmap
   sleep 2
   echo "<--- --- --->"
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
ip addr show "$STORAGENFSSRVIFCHOOSE" | grep "inet" | head -n 1 | awk '{print $2}' | sed 's/\/24//g' | awk -F. '{print $1"."$2"."$3}' > /tmp/c3d2-networking_storage_nfs_ip1.txt
STORAGENFSSRVIFIP=$(cat /tmp/c3d2-networking_storage_nfs_ip1.txt)
if [ -z "$STORAGENFSSRVIFIP" ]; then
   echo "" # dummy
   echo "" # dummy
   echo "ERROR: can't catch the interface ipv4 address"
   exit 1
fi
#
STORAGENFSSRVPORT=2049
STORAGENFSSRVTIMEOUT=1
#
if nc -w $STORAGENFSSRVTIMEOUT -t "$STORAGENFSSRVIFIP".10 $STORAGENFSSRVPORT; then
   echo "" # dummy
   echo "" # dummy
   echo "INFO: I was able to connect to $STORAGENFSSRVIFIP.10:${STORAGENFSSRVPORT}"
   sleep 2
   echo "" # dummy
   mkdir -p /c3d2-storage
STORAGENFSSRVSTATUS=$(mount | grep -c "c3d2-storage")
if [ X"$STORAGENFSSRVSTATUS" = X"1" ]; then
   echo "ERROR: storage is already mounted"
   sleep 2
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
   mount -t nfs "$STORAGENFSSRVIFIP".10:/mnt/zroot/storage/rpool /c3d2-storage -o soft,timeo=15,noatime
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
if [ -z "$STORAGEWEB" ]; then
   echo "<--- --- --->"
   echo "need davfs2"
   echo "<--- --- --->"
   sleep 2
   apt-get update
   sleep 2
   apt-get install davfs2
   sleep 2
   echo "<--- --- --->"
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
ip addr show "$STORAGEWEBSRVIFCHOOSE" | grep "inet" | head -n 1 | awk '{print $2}' | sed 's/\/24//g' | awk -F. '{print $1"."$2"."$3}' > /tmp/c3d2-networking_storage_web_ip1.txt
STORAGEWEBSRVIFIP=$(cat /tmp/c3d2-networking_storage_web_ip1.txt)
if [ -z "$STORAGEWEBSRVIFIP" ]; then
   echo "" # dummy
   echo "" # dummy
   echo "ERROR: can't catch the interface ipv4 address"
   exit 1
fi
#
#/ STORAGEWEBSRV=$STORAGEWEBSRVIFIP.10
STORAGEWEBSRVPORT=8080
STORAGEWEBSRVTIMEOUT=1
#
if nc -w $STORAGEWEBSRVTIMEOUT -t "$STORAGEWEBSRVIFIP".10 $STORAGEWEBSRVPORT; then
   echo "" # dummy
   echo "" # dummy
   echo "INFO: I was able to connect to $STORAGEWEBSRVIFIP.10:${STORAGEWEBSRVPORT}"
   sleep 2
   echo "" # dummy
   mkdir -p /c3d2-storage
STORAGEWEBSRVSTATUS=$(mount | grep -c "c3d2-storage")
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
   mount -t davfs -o username=webdav http://"$STORAGEWEBSRVIFIP".10:8080/rpool /c3d2-storage
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
if [ -z "$STORAGESSHFS" ]; then
   echo "<--- --- --->"
   echo "need sshfs"
   echo "<--- --- --->"
   sleep 2
   apt-get update
   sleep 2
   apt-get install sshfs
   sleep 2
   echo "<--- --- --->"
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
ip addr show "$STORAGESSHFSSRVIFCHOOSE" | grep "inet" | head -n 1 | awk '{print $2}' | sed 's/\/24//g' | awk -F. '{print $1"."$2"."$3}' > /tmp/c3d2-networking_storage_sshfs_ip1.txt
STORAGESSHFSSRVIFIP=$(cat /tmp/c3d2-networking_storage_sshfs_ip1.txt)
if [ -z "$STORAGESSHFSSRVIFIP" ]; then
   echo "" # dummy
   echo "" # dummy
   echo "ERROR: can't catch the interface ipv4 address"
   exit 1
fi
STORAGESSHFSSRVPORT=22
STORAGESSHFSSRVTIMEOUT=1
#
   echo "" # dummy
   echo "" # dummy
if nc -w $STORAGESSHFSSRVTIMEOUT -t "$STORAGESSHFSSRVIFIP".10 $STORAGESSHFSSRVPORT; then
   echo "" # dummy
   echo "" # dummy
   echo "INFO: I was able to connect to $STORAGESSHFSSRVIFIP.10:${STORAGESSHFSSRVPORT}"
   sleep 2
   echo "" # dummy
   mkdir -p /c3d2-storage
STORAGESSHFSSRVSTATUS=$(mount | grep -c "c3d2-storage")
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
   sshfs root@"$STORAGESSHFSSRVIFIP".10:/mnt/zroot/storage/rpool /c3d2-storage
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
if [ -z "$STORAGEFTP" ]; then
   echo "<--- --- --->"
   echo "need curlftpfs"
   echo "<--- --- --->"
   sleep 2
   apt-get update
   sleep 2
   apt-get install curlftpfs
   sleep 2
   echo "<--- --- --->"
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
ip addr show "$STORAGEFTPSRVIFCHOOSE" | grep "inet" | head -n 1 | awk '{print $2}' | sed 's/\/24//g' | awk -F. '{print $1"."$2"."$3}' > /tmp/c3d2-networking_storage_ftp_ip1.txt
STORAGEFTPSRVIFIP=$(cat /tmp/c3d2-networking_storage_ftp_ip1.txt)
if [ -z "$STORAGEFTPSRVIFIP" ]; then
   echo "" # dummy
   echo "" # dummy
   echo "ERROR: can't catch the interface ipv4 address"
   exit 1
fi
#
STORAGEFTPSRVPORT=21
STORAGEFTPSRVTIMEOUT=1
#
   echo "" # dummy
   echo "" # dummy
if nc -u -w $STORAGEFTPSRVTIMEOUT -t "$STORAGEFTPSRVIFIP".10 $STORAGEFTPSRVPORT; then
   echo "" # dummy
   echo "" # dummy
   echo "INFO: I was able to connect to $STORAGEFTPSRVIFIP.10:${STORAGEFTPSRVPORT}"
   sleep 2
   echo "" # dummy
   mkdir -p /c3d2-storage
STORAGEFTPSRVSTATUS=$(mount | grep -c "c3d2-storage")
if [ X"$STORAGEFTPSRVSTATUS" = X"1" ]; then
   echo "ERROR: storage is already mounted"
   sleep 2
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
 if [ -z "$STORAGEFTPAUTHFILE" ]; then
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
   curlftpfs -o ssl,no_verify_hostname,no_verify_peer "$STORAGEFTPSRVIFIP".10 /c3d2-storage
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
if [ "$DEBVERSION" = "7" ]; then
   echo "" # dummy
else
   echo "<--- --- --->"
   echo ""
   echo "ERROR: You need Debian 7 (Wheezy) Version"
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
if [ "$DEBVERSION" = "7" ]; then
   echo "" # dummy
else
   echo "<--- --- --->"
   echo ""
   echo "ERROR: You need Debian 7 (Wheezy) Version"
   exit 1
fi
### backup // ###
cp -pf /etc/network/interfaces /etc/network/interfaces_"$BACKUPDATE"
cp -pf /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf_"$BACKUPDATE"
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
echo "usage: $0 { hq-storage }"
;;
esac
exit 0

### ### ### PLITC ### ### ###
# EOF
