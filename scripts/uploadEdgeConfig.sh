#!/bin/bash

##### Setup #####

output_file="infrastructure/output.json"

# IoT Edge
remote_edgegateway_ip=$(jq -r .edgegateway_ip $output_file)
echo "Edge Gateway VM public IP: $remote_edgegateway_ip"
remote_target_dir="/home/edgegateway/"

# Provisioning Service
id_scope=$(jq -r .id_scope $output_file)

# Secrets
local_certs="openssl/certs"
local_private_keys="openssl/private"

##### Copy #####

# Secrets
scp "$local_certs/azure-iot-test-only.root.ca.cert.pem" "edgegateway@$remote_edgegateway_ip:$remote_target_dir"
scp "$local_certs/iot-edge-device-identity-edgegateway.fusiontech.iot-full-chain.cert.pem" "edgegateway@$remote_edgegateway_ip:$remote_target_dir"
scp "$local_private_keys/iot-edge-device-identity-edgegateway.fusiontech.iot.key.pem" "edgegateway@$remote_edgegateway_ip:$remote_target_dir"
scp "$local_certs/iot-edge-device-ca-edgeca.fusiontech.iot-full-chain.cert.pem" "edgegateway@$remote_edgegateway_ip:$remote_target_dir"
scp "$local_private_keys/iot-edge-device-ca-edgeca.fusiontech.iot.key.pem" "edgegateway@$remote_edgegateway_ip:$remote_target_dir"

# IoT Edge
cp iotedge/config-template.toml iotedge/config.toml
sed -i "s/SCOPE_ID_HERE/$id_scope/g" iotedge/config.toml
scp iotedge/config.toml "edgegateway@$remote_edgegateway_ip:$remote_target_dir"
scp iotedge/edgeconfig.sh "edgegateway@$remote_edgegateway_ip:$remote_target_dir"
