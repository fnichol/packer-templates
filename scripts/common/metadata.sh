#!/bin/sh -eux

dest=/etc/packer-metadata.json

mkdir -p "$(dirname "$dest")"
cp /tmp/metadata.json "$dest"
chmod 0444 "$dest"
