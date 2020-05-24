#!/bin/sh -eux

: "${MINIMIZE_FILESYSTEMS:-/}"

for fs in $MINIMIZE_FILESYSTEMS; do
  echo "Minimizing $fs"
  dd if=/dev/zero of="$fs/EMPTY" bs=1M || echo "dd exit code $? is suppressed"
  rm -f "$fs/EMPTY"
done

# Block until the empty file has been removed, otherwise, Packer
# will try to kill the box while the disk is still full and that's bad
sync
