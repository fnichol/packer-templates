#!/bin/sh -eux

while true; do
  if [ -f /etc/rc.firsttime ] \
    || [ -f /etc/rc.firsttime.run ] \
    || pgrep -qxf '/bin/ksh .*reorder_kernel'; then
    echo "Waiting on /etc/rc.firsttime..."
    sleep 1
  else
    # Delay just a little longer, then exit
    sleep 1
    exit 0
  fi
done
