#!/bin/bash -eux

rm -f "$(uname | tr [[:upper:]] [[:lower:]]).iso"

# eject installer disc
drutil eject
