#!/bin/sh -eux

rerun_attempts=5

if [ "$(syspatch -c | wc -l)" -gt 0 ]; then
  while true; do
    if pgrep -qxf '/bin/ksh .*reorder_kernel'; then
      echo "Waiting on reorder_kernel..."
      sleep 1
    else
      echo "Running syspatch(8) to apply all outstanding binary patches"
      set +e
      syspatch
      ec=$?
      set -e
      case $ec in
        # If exit code == 0 then we are done, break and reboot
        0)
          break
          ;;
        # If exit code == 2 then retry syspatch a number of times. Note that
        # exit code of 2 in this case may signal that syspatch was upgraded
        # when applying a syspatch set
        2)
          rerun_attempts=$((rerun_attempts - 1))
          if [ $rerun_attempts -le 0 ]; then
            echo "xxx Failed to re-run syspatch multiple times, aborting" 2>&1
            exit 10
          fi
          ;;
      esac
    fi
  done
fi

sync
echo "Rebooting..."
reboot
