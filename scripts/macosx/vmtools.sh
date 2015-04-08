#!/bin/bash -eux

home_dir="$(python -c 'import pwd; print pwd.getpwnam("vagrant").pw_dir')"

case "$PACKER_BUILDER_TYPE" in

virtualbox-iso|virtualbox-ovf)
    echo "VirtualBox not currently supported, sadface"
    ;;

vmware-iso|vmware-vmx)
    iso_name="$(uname | tr [[:upper:]] [[:lower:]]).iso"
    mount_point="$(mktemp -d /tmp/vmware-tools.XXXX)"
    #Run install, unmount ISO and remove it
    cd $home_dir
    hdiutil attach $iso_name -mountpoint "$mount_point"
    installer -pkg "$mount_point/Install VMware Tools.app/Contents/Resources/VMware Tools.pkg" -target /
    # This usually fails
    hdiutil detach "$mount_point" || true
    rm -rf $home_dir/$iso_name
    rmdir $mount_point

    # Point Linux shared folder root to that used by OS X guests,
    # useful for the Hashicorp vmware_fusion Vagrant provider plugin
    mkdir /mnt
    ln -sf /Volumes/VMware\ Shared\ Folders /mnt/hgfs
    ;;

parallels-iso|parallels-pvm)
    echo "Parallels not currently supported, sadface"
    ;;

*)
    echo "Unknown Packer Builder Type >>$PACKER_BUILDER_TYPE<< selected."
    echo "Known are virtualbox-iso|virtualbox-ovf|vmware-iso|vmware-vmx|parallels-iso|parallels-pvm."
    ;;
esac
