#!/bin/bash

tf_output="infrastructure/output.json"

# Variables
rg_name=$(jq -r .resource_group_name $tf_output)
iothub_name=$(jq -r .iothub_name $tf_output)
iothub_hostname=$(jq -r .iothub_hostname $tf_output)
dps_name=$(jq -r .dps_name $tf_output)
root_ca_name=$(jq -r .root_ca_name $tf_output)
vm_edgegateway_name=$(jq -r .vm_edgegateway_name $tf_output)

# Upgrade IoT Hub root authority to V2 (DigiCert)
az iot hub certificate root-authority set --hub-name $iothub_name --certificate-authority v2

# Create the DPS enrollment group
az iot dps enrollment-group create -n $dps_name -g $rg_name \
    --root-ca-name $root_ca_name \
    --secondary-root-ca-name $root_ca_name \
    --enrollment-id "EdgeDevicesGroup" \
    --provisioning-status "enabled" \
    --reprovision-policy "reprovisionandmigratedata" \
    --iot-hubs $iothub_hostname \
    --allocation-policy "hashed" \
    --edge-enabled true \
    --tags '{ "Environment": "Staging" }' \
    --props '{ "Debug": "false" }'

# Restarts the VM to activate the kernel likely upgraded by cloud-init
az vm restart -n $vm_edgegateway_name -g $rg_name