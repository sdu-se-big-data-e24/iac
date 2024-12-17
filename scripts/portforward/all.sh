#!/usr/bin/env bash

# Run all other scripts in this directory, besides this and terminate.sh

# Location of this script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for script in $(ls "$DIR" | grep -v "$(basename "$0")" | grep -v terminate.sh); do
  echo "Running $script"
  "$DIR/$script"
done
