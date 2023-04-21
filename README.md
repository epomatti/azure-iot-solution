# Azure IoT Solution

<img src=".assets/solution.png" />

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

Chage the hostname of the IoT Edge OS to `edgegateway` to match the certificates:

> IoT Edge requires it to be exact or have the first component in the FQDN
>
> Reboot is required

```sh
sudo nano /etc/hostname
sudo nano /etc/hosts
```

(Optional) Verify the cloud-init completion:

```sh
# Connect to the IoT Edge VM
ssh edgegateway@<public-ip>
ssh downstream@<public-ip>

# Check if the cloud-init status is "done", otherwise wait with "--wait"
cloud-init status

# Confirm that the IoT Edge runtime has been installed
iotedge --version

# Restart the VM to enable any Kernel updates
az vm restart -n "vm-fusiontech-edgegateway" -g "rg-fusiontech"
az vm restart -n "vm-fusiontech-downstream001" -g "rg-fusiontech"
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

# Add --iothub-hostname if using DPS to also test for IoT Hub
sudo iotedge check --iothub-hostname iot-fusiontech.azure-devices.net
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

### 5 - Deploy downstream devices

Upload the configuration:

```sh
bash scripts/uploadDownstreamDeviceConfig.sh
```

Register the downstream device:

```sh
# Get the IoT Edge Gateway device scope
az iot hub device-identity show --device-id "edgegateway.fusiontech.iot" --hub-name $(jq -r .iothub_name infrastructure/output.json) --query deviceScope -o tsv

# Create the downstream device identity
az iot hub device-identity create -n $(jq -r .iothub_name infrastructure/output.json) \
    -d "downstream-device-01.fusiontech.iot" \
    --device-scope "{deviceScope of gateway device}" \
    --am x509_ca
```

Verify the connectivity:

```sh
openssl s_client -connect edgegateway.fusiontech.iot:8883 -CAfile azure-iot-test-only.root.ca.cert.pem -showcerts
```

Run the downstream device code?

```sh
python3 downstream.py
```

## Secured provision

https://learn.microsoft.com/en-us/azure/iot-dps/concepts-device-oem-security-practices

https://learn.microsoft.com/en-us/azure/iot-dps/how-to-roll-certificates

https://aws.amazon.com/blogs/iot/enhancing-iot-device-security-using-hardware-security-modules-and-aws-iot-device-sdk/

https://learn.microsoft.com/en-us/azure/iot-edge/tutorial-configure-est-server?view=iotedge-1.4


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