# Azure IoT Solution

> ℹ️ All commands should be run from the project root

### 1 - Create the certificates

Start by creating the required certificates:

```sh
bash generate_certs.sh
```

### 2 - Create the Azure resources

Create the infrastructure:

```sh
terraform -chdir="infrastructure" init
terraform -chdir="infrastructure" apply -auto-approve
```

Run the extra configuration not available via Terraform:

```sh
bash scripts/terraform_extra.sh
```

### 3 - Configure the IoT Edge device

Run the configuration script locally:

```sh
# Run locally
bash upload_config_iotedge.sh
```

This will copy the prepared files to the IoT Edge device VM.

Now, in the remote VM shell, run the installation script:

```sh
# Run remotelly in the Azure VM shell
sudo bash edgeconfig.sh
```

Confirm that the IoT Edge runtime has been installed:

```sh
iotedge --version
sudo iotedge system status
sudo iotedge system logs
sudo iotedge check
```

### 4 - Deploy Modules

Create the deployment "RedisEdge":

```sh
az iot edge deployment create --deployment-id "redis-edge" \
    --hub-name "iotdymrobot" \
    --content "@iotedge/deployments/redis-edge.json" \
    --labels '{"Release":"001"}' \
    --target-condition "tags.Environment='Staging'" \
    --priority 10
```

Check the portal and the IoT device:

```
sudo iotedge list
```
