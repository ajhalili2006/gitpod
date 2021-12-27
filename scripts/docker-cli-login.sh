#!/bin/bash

if [[ $GITPOD_INSTANCE_ID != "" ]]; then
  eval $(gp env -e)
fi

if [[ $RHQCR_USERNAME == "" || $RHQCR_PASSWORD == "" ]]; then
  echo "Missing container registry login info, skipping..."
  exit
fi

docker login -u "$RHQCR_USERNAME" -p "$RHQCR_PASSWORD" quay.io
