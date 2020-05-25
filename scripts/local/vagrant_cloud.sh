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

metadata() {
  jq -r "$1" <"$METADATA"
}

need_cmd jq

box_tag="$(metadata .name)"
description="$(metadata .description)"
version="$(metadata .version)"
build_timestamp="$(metadata .build_timestamp)"
git_revision="$(metadata .git_revision)"
project_url="$(metadata .project_url)"
source_url="$(metadata .source_url)"

path="$(dirname "$METADATA")"
boxes_json="$(
  jq \
    --arg version "$version" \
    --arg path "$path" \
    '.versions[] | select($version).providers | map($path + "/" + .url)' \
    <"$METADATA"
)"

version_description="$description

* Project: $project_url
* Build Timestamp: $build_timestamp
* Git Revision: [$git_revision]($project_url/commit/$git_revision)
* Source: $source_url
"

# Calling `packer` within a Packer `local-shell` will attempt to reuse some of
# these environment variables, confusing it into thinking it's running in a
# plugin, etc. Instead, we will unset these variables from the environment.
unset PACKER_BUILD_NAME PACKER_BUILDER_TYPE PACKER_HTTP_ADDR \
  PACKER_PLUGIN_MAGIC_COOKIE PACKER_PLUGIN_MAX_PORT PACKER_PLUGIN_MIN_PORT \
  PACKER_RUN_UUID PACKER_WRAP_COOKIE

case "$VALIDATE" in
  "")
    subcommand=build
    ;;
  *)
    subcommand=validate
    ;;
esac

jq -n \
  '{
    builders: [
      {
        type: "null",
        communicator: "none"
      }
    ],
    "post-processors": []
  }' \
  | jq \
    --argjson boxes "$boxes_json" \
    --arg box_tag "$box_tag" \
    --arg version "$version" \
    --arg version_description "$version_description" \
    '."post-processors" += [$boxes[] | [
        {
          type: "artifice",
          files: [.]
        },
        {
          box_tag: $box_tag,
          type: "vagrant-cloud",
          version: $version,
          version_description: $version_description
        }
      ]]' \
  | packer "$subcommand" -
