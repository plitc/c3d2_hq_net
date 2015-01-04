
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

* Linux (Debian) - hq-printer support
   * cups

Features
========
* -

Platform
========
* Linux (Debian)

Usage
=====
    # usage: ./c3d2-networking.sh { network | hq-storage | hq-printer | config-backup }

Errata
======
* doesn't support iwconfig spaces

