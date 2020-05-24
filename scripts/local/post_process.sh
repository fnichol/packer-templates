#!/bin/sh -eux

die() {
  printf -- "\nxxx %s\n\n" "$1" >&2
  exit 1
}

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    die "Required command '$1' not found on local PATH"
  fi
}

checksum() {
  case "$(uname -s)" in
    Darwin)
      need_cmd shasum
      shasum -a 256 "$@" | cut -d ' ' -f 1
      ;;
    *)
      need_cmd sha256sum
      sha256sum "$@" | cut -d ' ' -f 1
      ;;
  esac
}

need_cmd jq

dest="$BOX_BASENAME.metadata.json"

if [ ! -f "$dest" ]; then
  jq \
    --arg box_basename "$(basename "$BOX_BASENAME")" \
    --arg version "$VERSION" \
    '. + {
      box_basename: $box_basename,
      versions: [
        {version: $version, providers: []}
      ]}' \
    <"$METADATA_FILE" >"$dest"
fi

case "$BUILD_TYPE" in
  qemu)
    provider=qemu
    file="$BOX_BASENAME.$provider.box"
    ;;
  virtualbox-iso)
    provider=virtualbox
    file="$BOX_BASENAME.$provider.box"
    ;;
  vmware-iso)
    provider=vmware_desktop
    file="$BOX_BASENAME.vmware.box"
    ;;
  *)
    die "Unsupported build_type: '$BUILD_TYPE' when post-processing"
    ;;
esac

if ! jq -e --arg provider "$provider" --arg version "$VERSION" \
  '.versions[] | select(.version == $version) | select(.name == $provider)' \
  <"$dest" >/dev/null; then

  checksum="$(checksum "$file")"

  jq \
    --arg name "$provider" \
    --arg version "$VERSION" \
    --arg file "$(basename "$file")" \
    --arg checksum_type "sha256" \
    --arg checksum "$checksum" \
    '(.versions[] | select(.version == $version)).providers += [{
      name: $name,
      url: $file,
      checksum_type: $checksum_type,
      checksum: $checksum
    }]' <"$dest" >"$dest.$$"
  mv "$dest.$$" "$dest"
fi
