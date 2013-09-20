#!/bin/bash -eux

if [ -f /home/vagrant/.vbox_version ]; then
    mkdir /tmp/vbox
    VER=$(cat /home/vagrant/.vbox_version)
    mount -o loop VBoxGuestAdditions_$VER.iso /tmp/vbox 
    sh /tmp/vbox/VBoxLinuxAdditions.run
    umount /tmp/vbox
    rmdir /tmp/vbox
    rm *.iso
fi

if [ -f /home/vagrant/.vmfusion_version ]; then
    #Set Linux-specific paths and ISO filename
    home_dir="/home/vagrant"
    iso_name="linux.iso"
    mount_point="/tmp/vmware-tools"
    #Run install, unmount ISO and remove it
    mkdir ${mount_point}
    cd ${home_dir}
    /bin/mount -o loop ${iso_name} ${mount_point}
    tar zxf ${mount_point}/*.tar.gz

    # VMwareTools 9.2.2-893683 doesn't work with the 3.8 kernel
    if [ -f "${mount_point}/VMwareTools-9.2.2-893683.tar.gz" ]; then
      # Create symlinks so the vmware-install.pl can find header files
      src="/lib/modules/$(uname -r)/build/include/linux"
      cd ${src}
      for f in utsrelease.h autoconf.h uapi/linux/version.h ; do
        ln -sf ../generated/$f
      done ; unset f

      # Mount floppy device with patches
      mkdir -p /mnt/floppy
      modprobe floppy
      mount -t vfat /dev/fd0 /mnt/floppy

      cd ${home_dir}/vmware-tools-distrib

      # Patch so vmci successfully compiles
      cd ${home_dir}/vmware-tools-distrib/lib/modules/source
      if [ ! -f vmci.tar.orig ]; then
        cp vmci.tar vmci.tar.orig
      fi
      rm -rf vmci-only
      tar xf vmci.tar
      cd ${home_dir}/vmware-tools-distrib/lib/modules/source/vmci-only
      patch -p1 < /mnt/floppy/vmware9.k3.8rc4.patch
      cd ${home_dir}/vmware-tools-distrib/lib/modules/source
      tar cf vmci.tar vmci-only
      rm -rf vmci-only

      # patch so vmhgfs successfully compiles
      cd ${home_dir}/vmware-tools-distrib/lib/modules/source
      if [ ! -f vmhgfs.tar.orig ]; then
        cp vmhgfs.tar vmhgfs.tar.orig
      fi
      rm -rf vmhgfs-only
      tar xf vmhgfs.tar
      cd ${home_dir}/vmware-tools-distrib/lib/modules/source/vmhgfs-only/shared
      patch -p1 < /mnt/floppy/vmware9.compat_mm.patch
      cd ${home_dir}/vmware-tools-distrib/lib/modules/source
      tar cf vmhgfs.tar vmhgfs-only
      rm -rf vmhgfs-only

      umount /mnt/floppy
      rmdir /mnt/floppy
    fi

    cd ${home_dir}/vmware-tools-distrib && ./vmware-install.pl --default
    /bin/umount ${mount_point}
    /bin/rm -rf ${home_dir}/${iso_name} ${home_dir}/vmware-tools-distrib
    rmdir ${mount_point}
fi

mkdir /home/vagrant/.ssh
wget --no-check-certificate \
    'https://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' \
    -O /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh
