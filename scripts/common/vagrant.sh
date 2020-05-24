#!/bin/sh -eux

pubkey_url="https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub"
dest="$HOME_DIR/.ssh/authorized_keys"

mkdir -p "$(dirname "$dest")"

if command -v wget >/dev/null 2>&1; then
  wget --no-check-certificate "$pubkey_url" -O "$dest"
elif command -v curl >/dev/null 2>&1; then
  curl --insecure --location "$pubkey_url" >"$dest"
elif [ "$(uname)" = "OpenBSD" ] && command -v ftp >/dev/null 2>&1; then
  http_proxy="" ftp -S dont -o "$dest" "$pubkey_url"
else
  echo "Cannot download vagrant public key"
  exit 1
fi
chown -R vagrant "$HOME_DIR/.ssh"
chmod -R go-rwsx "$HOME_DIR/.ssh"
