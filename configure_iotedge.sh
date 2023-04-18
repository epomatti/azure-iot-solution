#!/bin/bash

##### Setup #####

output_file="infrastructure/output.json"

# IoT Edge
remote_edgegateway_ip=$(jq .edgegateway_ip $output_file)
echo "Edge Gatewa VM public IP: $output_file"
remote_target_dir="/home/edgegateway/"

# Provisioning Service
id_scope=$(jq .id_scope $output_file)
echo "Uploading files to IP $id_scope"

# Secrets
local_certs="openssl/certs"
local_private_keys="openssl/private"

##### Copy #####

# Secrets
scp "$local_certs/iot-edge-device-identity-EdgeGateway-full-chain.cert.pem" "edgegateway@$remote_edgegateway_ip:$remote_target_dir"
scp "$local_private_keys/iot-edge-device-identity-EdgeGateway.key.pem" "edgegateway@$remote_edgegateway_ip:$remote_target_dir"

# IoT Edge
cp iotedge/config-template.toml iotedge/config.toml
sed -i "s/SCOPE_ID_HERE/$id_scope/g" iotedge/config.toml
scp iotedge/config.toml "edgegateway@$remote_edgegateway_ip:$remote_target_dir"
