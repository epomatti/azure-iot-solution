#!/bin/bash

sudo mkdir /var/secrets
sudo mkdir /var/secrets/aziot

sudo mv iot-edge-device-identity-EdgeGateway-full-chain.cert.pem /var/secrets/aziot/
sudo mv iot-edge-device-identity-EdgeGateway.key.pem /var/secrets/aziot/

sudo mv config.toml /etc/aziot/

sudo iotedge config apply