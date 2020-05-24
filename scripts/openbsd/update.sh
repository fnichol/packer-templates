#!/bin/sh -eux

if [ "$(syspatch -c | wc -l)" -gt 0 ]; then
  while true; do
    if pgrep -qxf '/bin/ksh .*reorder_kernel'; then
      echo "Waiting on reorder_kernel..."
      sleep 1
    else
      echo "Running syspatch(8) to apply all outstanding binary patches"
      syspatch
      sync
      echo "Rebooting..."
      reboot
    fi
  done
fi
