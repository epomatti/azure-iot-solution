#!/bin/bash

##### Setup #####

output_file="infrastructure/output.json"

# IoT Edge
downstream_device_01_ip=$(jq -r .downstream_device_01_ip $output_file)
echo "Downstream device VM public IP: $downstream_device_01_ip"
remote_target_dir="/home/downstream/"

# Secrets
local_certs="openssl/certs"
local_private_keys="openssl/private"

##### Copy #####

# Secrets
scp "$local_certs/iot-device-downstream-device-01.fusiontech.iot-full-chain.cert.pem" "downstream@$downstream_device_01_ip:$remote_target_dir"
scp "$local_private_keys/iot-device-downstream-device-01.fusiontech.iot.key.pem" "downstream@$downstream_device_01_ip:$remote_target_dir"

# Downstream device
scp downstream-device/.env "downstream@$downstream_device_01_ip:$remote_target_dir"
scp downstream-device/downstream.py "downstream@$downstream_device_01_ip:$remote_target_dir"
scp downstream-device/downstreamConfig.sh "downstream@$downstream_device_01_ip:$remote_target_dir"
scp downstream-device/requirements.txt "downstream@$downstream_device_01_ip:$remote_target_dir"
