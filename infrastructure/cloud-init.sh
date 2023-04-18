#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

sudo apt update
sudo apt upgrade -y

sudo wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo rm packages-microsoft-prod.deb

