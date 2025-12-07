#!/usr/bin/env bash
set -e

FILE=$1
IMAGE=$2

sed -i "s#^\(\s*image:\s*\).*#\1${IMAGE}#g" "$FILE"

echo "Patched $FILE with image: $IMAGE"
