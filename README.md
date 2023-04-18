# azure-iot-solution

```sh
bash generate_certs.sh
```

The certificates were generated and copied to the Terraform working directory.


```
cd infrastructure

terraform init
terraform apply -auto-approve
```



```sh
az vm restart -n vmiotedge -g IoTEdgeResources
```
