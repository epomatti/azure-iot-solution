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
az iot edge deployment create --deployment-id "redis-edge" \
    --hub-name $(jq -r .iothub_name infrastructure/output.json) \
    --content "@iotedge/deployments/redis-edge.json" \
    --labels '{"Release":"001"}' \
    --target-condition "tags.Environment='Staging'" \
    --priority 10
```

Check the portal and the IoT device:

```sh
# List the modules in the Azure VM
iotedge list
```

## Python device local development

```
cd device
```

```
pipenv install
pipenv shell
pipenv run python device.py
```
