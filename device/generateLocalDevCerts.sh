#!/bin/bash

cd ../openssl
bash ./certGen.sh create_edge_device_identity_certificate "DeviceLocalDev"

cd ../device
mkdir certs
cp ../openssl/certs/iot-edge-device-identity-DeviceLocalDev-full-chain.cert.pem certs/
cp ../openssl/private/iot-edge-device-identity-DeviceLocalDev.key.pem certs/
