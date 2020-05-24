#!/bin/sh -eux

while true; do
  if rcctl ls started | grep -q '^cron$' >/dev/null; then
    # Delay just a little longer, then exit
    sleep 1
    exit 0
  else
    echo "Waiting on cron(8) service to start"
    sleep 1
  fi
done
