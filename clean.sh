#!/bin/bash

# This script will clean locally generated assets
rm -rf ./openssl
rm -f ./device/.env
rm -f ./downstream-device/.env
rm -rf ./infrastructure/secrets
rm -f ./infrastructure/terraform.tfstate
rm -f ./infrastructure/terraform.tfstate.backup
rm -f ./iotedge/config.toml