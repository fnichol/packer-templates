#!/bin/sh -eux

while true; do
  if pgrep -qxf '/bin/ksh .*reorder_kernel'; then
    echo "Waiting on reorder_kernel..."
    sleep 1
  else
    # Delay just a little longer, then exit
    sleep 1
    exit 0
  fi
done
