# azure-iot-solution

Start by creating the required certificates:

```sh
bash generate_certs.sh
```

The certificates were generated and copied to the Terraform working directory.

Enter the Terraform directory with `cd infrastructure` and create the resources:

```sh
terraform init
terraform apply -auto-approve
```

There is no official TF support for enrollment groups, so create it with the CLI:

```sh
az iot dps enrollment-group create -n "dpsdymrobot" -g "rgdymrobot" \
    --root-ca-name "TerraformRootCA" \
    --secondary-root-ca-name "TerraformRootCA" \
    --enrollment-id "EdgeDevicesGroup" \
    --provisioning-status "enabled" \
    --reprovision-policy "reprovisionandmigratedata" \
    --iot-hubs "iotdymrobot.azure-devices.net" \
    --allocation-policy "hashed" \
    --edge-enabled true \
    --tags '{ "Environment": "Staging" }' \
    --props '{ "Debug": "false" }'
```

The kernel should have been upgraded. Restart the VM for it to take effect:

```sh
az vm restart -n vm-dymrobot-edgegateway -g rgdymrobot
```

Confirm that the IoT Edge runtime has been installed:

```sh
iotedge --version
sudo iotedge system status
```
