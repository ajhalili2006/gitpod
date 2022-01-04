#!/usr/bin/env bash

UPSTREAM=${GP_UPSTREAM_REMOTE:-"https://github.com/gitpod-io/gitpod"}
FORK_MAIN_BRANCH=${FORK_MAIN_BRANCH:-"ajhalili2006/develop"}

echo "====> Setting upstream remote to $UPSTREAM"
git remote add upstream "$UPSTREAM" || git remote set-url upstream "$UPSTREAM"

echo "====> Fetching resources..."
git fetch --verbose --all --progress

echo "====> Updating main branch with upstream..."
git switch upstream/develop
git pull upstream main --rebase --verbose
git push origin upstream/develop --verbose --progress

echo "====> Synchorizing $FORK_MAIN_BRANCH against upstream..."
git switch "$FORK_MAIN_BRANCH"
git pull upstream main --no-rebase --verbose --signoff
git push origin "$FORK_MAIN_BRANCH"