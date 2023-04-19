# Azure IoT Solution

> ℹ️ All commands should be run from the project root

## Cloud IoT

### 1 - Create the certificates

Start by creating the required certificates:

```sh
bash scripts/generateCerts.sh
```

### 2 - Create the Azure resources

Create the infrastructure:

```sh
terraform -chdir="infrastructure" init
terraform -chdir="infrastructure" apply -auto-approve
```

Run the extra configuration not available via Terraform:

```sh
bash scripts/terraformExtra.sh
```

(Optional) Verify the cloud-init completion:

```sh
# Connect to the IoT Edge VM
ssh edgegateway@<public-ip>

# Check if the cloud-init status is "done", otherwise wait with "--wait"
cloud-init status

# Confirm that the IoT Edge runtime has been installed
iotedge --version

# Restart the VM to enable any Kernel updates
az vm restart -n "vm-fusiontech-edgegateway" -g "rg-fusiontech"
```

### 3 - Configure the IoT Edge device

Run the configuration script locally:

```sh
# Run locally
bash scripts/uploadEdgeConfig.sh
```

This will copy the prepared files to the IoT Edge device VM.

Now, in the remote VM shell, run the installation script:

```sh
# Run remotelly in the Azure VM shell
sudo bash edgeconfig.sh
```

Confirm that the IoT Edge runtime has been installed:

```sh
sudo iotedge system logs
sudo iotedge check
```

### 4 - Deploy Modules

Create the deployment "RedisEdge":

```sh
az iot edge deployment create --deployment-id "gateway" \
    --hub-name $(jq -r .iothub_name infrastructure/output.json) \
    --content "@iotedge/deployments/gateway.json" \
    --labels '{"Release":"001"}' \
    --target-condition "tags.Environment='Staging'" \
    --priority 10
```

Check the portal and the IoT device:

```sh
# List the modules in the Azure VM
iotedge list
```

## Secured provision

https://learn.microsoft.com/en-us/azure/iot-dps/concepts-device-oem-security-practices

https://learn.microsoft.com/en-us/azure/iot-dps/how-to-roll-certificates

https://aws.amazon.com/blogs/iot/enhancing-iot-device-security-using-hardware-security-modules-and-aws-iot-device-sdk/


## Python development

### Local Python

```
cd device
```

Create the local devevelopment device cerficiates:

```sh
bash generateDevCerts.sh
```

Create the `.env` and edit the `PROVISIONING_IDSCOPE` variable:

```sh
cp .example.env .env
```

Install and run the device:

```sh
pipenv install --dev
pipenv shell
python device.py
```

### Docker

```sh
docker build . -t iothub-pydevice:latest
```

```sh
docker run --rm iothub-pydevice:latest arg1 arg2
```

## Referece

https://github.com/Azure/iotedge-vm-deploy