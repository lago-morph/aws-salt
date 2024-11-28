#!/bin/bash
#
# Set up repositories
export DEBIAN_FRONTEND=noninteractive
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | sudo tee /etc/apt/sources.list.d/salt.sources
# pin version to latest LTS
echo 'Package: salt-*
Pin: version 3006.*
Pin-Priority: 1001' | sudo tee /etc/apt/preferences.d/salt-pin-1001
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install salt-minion -y
sudo systemctl enable salt-minion && sudo systemctl start salt-minion
