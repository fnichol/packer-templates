#!/bin/sh -eux

cat <<RCCONF >>/etc/rc.conf.local

# Enable NFS server for Vagrant synced folders
portmap_flags=""
mountd_flags=""
nfsd_flags="-tun 4"
RCCONF
