#!/bin/bash -eux

if [ "$PACKER_BUILDER_TYPE" = "vmware" ]; then
  version_file="/home/vagrant/.vmfusion_version"
  mkdir -p $(dirname $version_file) 
  touch $version_file
fi
