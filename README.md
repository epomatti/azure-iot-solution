# azure-iot-solution

> ℹ️ All commands should be run from the project root

### 1 - Create the certificates

Start by creating the required certificates:

```sh
bash generate_certs.sh
```

The certificates are generated and copied to the Terraform working directory.

### 2 - Create the Azure resources

Create the infrastructure:

```sh
terraform -chdir="infrastructure" init
terraform -chdir="infrastructure" apply -auto-approve
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

### 3 - Configure the IoT Edge device

Run the configuration script locally. The script will read data form `infrastructure/output.json` values using `jq`.

```sh
bash configure_iotedge.sh
```

This will copy the prepared files to the IoT Edge device VM.

Now in the remote VM shell, run the installation script:

```sh
# In the remote Azure VM shell
sudo bash edgeconfig.sh
```

Confirm that the IoT Edge runtime has been installed:

```sh
iotedge --version
sudo iotedge system status
sudo iotedge system logs
sudo iotedge check
```
