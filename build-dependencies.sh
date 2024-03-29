#!/bin/bash

# Enable debugging and strict error handling (immediate exit on error)
set -exu
set -o pipefail

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

#current_go_version=$(go version | awk '{print $3}')
#if [[ "$current_go_version" != "$required_go_version" ]]; then
#    echo "Error: Required Go version $required_go_version is not installed. Please install the correct version and try again."
#    exit 1
#fi

# Check if Bazel is installed
if ! command -v bazel &> /dev/null; then
    echo "Error: Bazel is not installed. Please install Bazel and try again."
    exit 1
fi

# Check Bazelisk version
current_bazelisk_version=$(bazel version | grep -i "Bazelisk version" | awk '{print $3}')
if [[ "$(printf '%s\n' "$min_bazelisk_version" "$current_bazelisk_version" | sort -V | head -n1)" != "$min_bazelisk_version" ]]; then
    echo "Error: Minimum required Bazelisk version is $min_bazelisk_version. Please upgrade Bazelisk and try again."
    exit 1
fi

# Check Bazelisk version
#required_bazelisk_version="v1.19.0"
#current_bazelisk_version=$(bazel version | grep -i "Bazelisk version" | awk '{print $3}')
#if [[ "$current_bazelisk_version" != "$required_bazelisk_version" ]]; then
#    echo "Error: Required Bazelisk version $required_bazelisk_version is not installed. Please install the correct version and try again."
#    exit 1
#fi

echo "All required dependencies are installed."

# directories
DEPENDENCIES_DIR=./dependencies
PRYSM_DIR=./prysm
GETH_DIR=./go-ethereum

# Prysm version 4.2.1
PRYSM="https://github.com/prysmaticlabs/prysm"
#go get .cmd/beacon-chain
#go build -o=../beacon-chain .cmd/beacon-chain
#BEACON_CHAIN_BINARY="https://github.com/prysmaticlabs/prysm/releases/download/v4.2.1/beacon-chain-v4.2.1-linux-amd64"
#VALIDATOR_BINARY="https://github.com/prysmaticlabs/prysm/releases/download/v4.2.1/validator-v4.2.1-linux-amd64"
#PRYSMCTL_BINARY="https://github.com/prysmaticlabs/prysm/releases/download/v4.2.1/prysmctl-v4.2.1-linux-amd64"

# Go-Ethereum version x.x.x
GETH="https://github.com/ethereum/go-ethereum"

# todo: Reihenfolge klören mit download der binaries und in welchen Ordner und ausführen und so

# TODO: checken ob die notwendigen Programme installiert sind
go version # go version go1.22.0 linux/amd64

bazel version # Bazelisk version: v1.19.0 ...

( mkdir -p $DEPENDENCIES_DIR && cd $DEPENDENCIES_DIR )

# Clone Prysm repository
( git clone $PRYSM && cd $PRYSM_DIR )

# Build Prysm binaries with Bazel
( bazel build //cmd/beacon-chain:beacon-chain && bazel build //cmd/validator:validator && bazel build //cmd/prysmctl:prysmctl )
( cp ./bazel-bin/cmd/prysmctl/prysmctl_/prysmctl ../prysmctl )
( cp ./bazel-bin/cmd/beacon-chain/beacon-chain_/beacon-chain ../beacon-chain )
( cp ./bazel-bin/cmd/validator/validator_/validator ../validator )
( cd .. )

# Clone Go-Ethereum repository
( git clone $GETH && cd $GETH_DIR )

# Build Go-Ethereum binaries
( make all )
( cp ./build/bin/geth ../geth )
( cp ./build/bin/bootnode ../bootnode )

( cd ../.. )
