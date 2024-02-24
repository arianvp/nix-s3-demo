#!/bin/sh

set -eu
set -f # disable globbing
export IFS=' '

# shellcheck disable=SC2086
echo "Uploading paths" $OUT_PATHS
# shellcheck disable=SC2086
exec nix copy --to "s3://cache20240224120542829900000001" $OUT_PATHS