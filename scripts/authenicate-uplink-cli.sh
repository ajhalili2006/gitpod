#!/usr/bin/bash
# shellcheck shell=bash

if [[ $GITPOD_INSTANCE_ID == "" ]] && [[ $1 == "" ]]; then
  echo "Usage: $0 [STORJ DCS ACCESS GRANT]"
fi

if [[ $GP_LOCALAPP_BUCKET_ACCESS_GRANT == "" &&  $GITPOD_INSTANCE_ID != "" ]]; then
  echo "Missing access grant on variable GP_LOCALAPP_BUCKET_ACCESS_GRANT, skipping..."
fi

if [[ $GITPOD_INSTANCE_ID != "" ]]; then
  "$GITPOD_REPO_ROOT/scripts/gp-uplink" import "$GP_LOCALAPP_BUCKET_ACCESS_GRANT"
else
   uplink import $1
fi