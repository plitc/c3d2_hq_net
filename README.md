
Background
==========
set (c3d2.de hq) ipv4/ipv6 network configs

Dependencies
============
* Linux (Debian) - network support
   * iputils-ping
   * arping
   * arp-scan
   * dialog
   * ifconfig
   * tcpdump
   * vlan

* Linux (Debian) - hq-storage support
   * cifs-utils
   * nfs-common
   * portmap
   * davfs2
   * sshfs
   * curlftpfs

* Linux (Debian) - hq-printer support
   * cups

Features
========
* sniff a little bit the network with tcpdump
* prefix generated from Proto: IPv4 (0x0800)
* router lookup from Proto: OSPFv2
* static DNS list
* mount remote HQ Storage Server

Platform
========
* Linux (Debian 8/jessie)

Usage
=====
    # usage: ./c3d2-networking.sh { network | hq-storage | config-backup }

Errata
======
* doesn't support iwconfig spaces
* ftps is very slow

