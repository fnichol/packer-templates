#!/bin/sh -eux

mkdir -p "$(dirname "$METADATA_FILE")"
cat <<JSON >"$METADATA_FILE"
{
  "name": "$_METADATA_NAME",
  "version": "$_METADATA_VERSION",
  "description": "$_METADATA_DESCRIPTION",
  "build_timestamp": "$_METADATA_BUILD_TIMESTAMP",
  "git_revision": "$_METADATA_GIT_REVISION",
  "template_name": "$_METADATA_TEMPLATE_NAME",
  "project_url": "$_METADATA_PROJECT_URL",
  "source_url": "$_METADATA_SOURCE_URL"
}
JSON
chmod 0444 "$METADATA_FILE"
