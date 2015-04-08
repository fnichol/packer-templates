#!/bin/bash -eux

# disable swap
launchctl unload -wF /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist

rm -f /private/var/vm/swapfile*
rm -f /private/var/vm/sleepimage

dd if=/dev/zero of=/EMPTY bs=1000000
rm -f /EMPTY
# Block until the empty file has been removed, otherwise, Packer
# will try to kill the box while the disk is still full and that's bad
sync

# re-enable swap
launchctl load -wF /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist
