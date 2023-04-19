#!/bin/bash

cd ../openssl
bash ./certGen.sh create_edge_device_identity_certificate "device-localdev"

cd ../device
mkdir certs
cp ../openssl/certs/iot-edge-device-identity-device-localdev-full-chain.cert.pem certs/
cp ../openssl/private/iot-edge-device-identity-device-localdev.key.pem certs/
