#!/usr/bin/bash
# shellcheck shell=bash disable=SC2046
set -e

GP_LOCALAPP_BUCKET_ACCESS_GRANT=${GP_LOCALAPP_BUCKET_ACCESS_GRANT:-$1}

if ! command -v uplink>>/dev/null; then
  echo "error: Storj Uplink doesn't exist on PATH, perhaps not installed? Check https://docs.storj.io/dcs/downloads/download-uplink-cli"
  echo "error: for the install guide."
  exit 1
fi

if [[ $GP_LOCALAPP_BUCKET_ACCESS_GRANT == "" ]]; then
  echo "Usage: $0 [STORJ DCS ACCESS GRANT]"
  echo
  echo "Tip: Use GP_LOCALAPP_BUCKET_ACCESS_GRANT variable to set this instead of passing it as an script argument,"
  echo "     through risking your access grant against unauthorized access."
  exit 1
fi

# TODO: Revisit uplink import help stuff because force flag sunds kinda sussy.
if [[ $GITPOD_INSTANCE_ID != "" ]]; then
  echo "info: Refreshing variables before authenicating against Storj Uplink, this should take a while..."
  eval $(gp env -e)
  "$GITPOD_REPO_ROOT/scripts/gp-uplink" import "$GP_LOCALAPP_BUCKET_ACCESS_GRANT" --force
else
   uplink import "$GP_LOCALAPP_BUCKET_ACCESS_GRANT" --force
fi
