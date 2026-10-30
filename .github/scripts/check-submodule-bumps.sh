#!/bin/bash
###########################################
## Check submodule bumps
##
## Written: David Harris, david_harris@hmc.edu
## Created: 30 October 2026
## Modified:
##
## Purpose: Fail a pull request that moves a submodule backwards or off its upstream branch.
##          Usage: check-submodule-bumps.sh <base commit> <head commit>
##          For each submodule the head changes relative to its merge base with the base commit,
##          the new commit must descend from the commit the base points to (so a stale checkout
##          committed by accident cannot roll it back), and it must be on the submodule's branch
##          (the branch in .gitmodules, else the default branch), so a commit that exists only on
##          a fork or an unmerged pull request cannot be pinned.
##
## A component of the CORE-V-WALLY configurable RISC-V project.
## https://github.com/openhwfoundation/cvw
##
## Copyright (C) 2021-26 Harvey Mudd College & Oklahoma State University
##
## SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
##
################################################################################################

set -euo pipefail

base=$1
head=$2
mergebase=$(git merge-base "$base" "$head")
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
status=0

# Commit a submodule's gitlink names in a superproject commit, or nothing if it has none
gitlink() {
  git ls-tree "$1" -- "$2" | awk '$2 == "commit" {print $3}'
}

for path in $(git config -f .gitmodules --get-regexp '\.path$' | awk '{print $2}'); do
  old=$(gitlink "$mergebase" "$path")
  new=$(gitlink "$head" "$path")
  [[ -z $new || $new == "$old" ]] && continue # unchanged or removed by this pull request
  name=$(git config -f .gitmodules --get-regexp '\.path$' | awk -v p="$path" '$2 == p {print $1}' | sed 's/\.path$//')
  url=$(git config -f .gitmodules --get "$name.url")
  branch=$(git config -f .gitmodules --get "$name.branch" || true)
  current=$(gitlink "$base" "$path")
  echo "$path: ${current:-none} -> $new"

  # Fetch commits only (no trees or blobs), which is enough to compare ancestry
  repo="$scratch/$(basename "$path")"
  git init -q --bare "$repo"
  if [[ -z $branch ]]; then
    branch=$(git ls-remote --symref "$url" HEAD | awk '/^ref:/ {sub("refs/heads/", "", $2); print $2}')
  fi
  git -C "$repo" fetch -q --filter=tree:0 "$url" "refs/heads/$branch:refs/heads/$branch"

  if ! git -C "$repo" merge-base --is-ancestor "$new" "$branch" 2>/dev/null; then
    echo "::error::$path: $new is not on branch $branch of $url"
    status=1
  elif [[ -n $current ]] && ! git -C "$repo" merge-base --is-ancestor "$current" "$new"; then
    echo "::error::$path: $new does not contain $current, which the base branch points to; this would move $path backwards"
    status=1
  fi
done

exit $status
