#!/bin/bash

cd openssl

curl https://raw.githubusercontent.com/Azure/iotedge/main/tools/CACertificates/certGen.sh -o certGen.sh
curl https://raw.githubusercontent.com/Azure/iotedge/main/tools/CACertificates/openssl_root_ca.cnf -o openssl_root_ca.cnf

bash ./certGen.sh create_root_and_intermediate
bash ./certGen.sh create_edge_device_identity_certificate "EdgeGateway"

mkdir ../infrastructure/secrets
cp certs/azure-iot-test-only.root.ca.cert.pem ../infrastructure/secrets/
cp certs/iot-edge-device-identity-EdgeGateway-full-chain.cert.pem ../infrastructure/secrets/
cp private/iot-edge-device-identity-EdgeGateway.key.pem ../infrastructure/secrets/
