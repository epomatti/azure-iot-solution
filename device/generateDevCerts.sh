#!/bin/bash

cd ../openssl
bash ./certGen.sh create_edge_device_identity_certificate "device-localdev"
bash ./certGen.sh create_edge_device_identity_certificate "device-dockerdev"

cd ../device

mkdir certs/local
mkdir certs/docker

cp ../openssl/certs/iot-edge-device-identity-device-localdev-full-chain.cert.pem certs/local/
cp ../openssl/private/iot-edge-device-identity-device-localdev.key.pem certs/local/

cp ../openssl/certs/iot-edge-device-identity-device-dockerdev-full-chain.cert.pem certs/docker/
cp ../openssl/private/iot-edge-device-identity-device-dockerdev.key.pem certs/docker/