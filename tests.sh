#!/bin/bash

set -exu
set -o pipefail

# NETWORK_DIR=./network
# NUM_NODES=2
# NODE_DIR=
# mkdir -p $NETWORK_DIR

# Minimum required versions
min_go_version="go1.22.0"
min_bazelisk_version="v1.19.0"

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "Error: Go is not installed. Please install Go and try again."
    exit 1
fi

# Check Go version
current_go_version=$(go version | awk '{print $3}')
if [[ "$(printf '%s\n' "$min_go_version" "$current_go_version" | sort -V | head -n1)" != "$min_go_version" ]]; then
    echo "Error: Minimum required Go version is $min_go_version. Please upgrade Go and try again."
    exit 1
fi

