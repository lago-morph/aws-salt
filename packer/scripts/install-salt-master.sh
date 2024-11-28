#!/bin/bash
#
export DEBIAN_FRONTEND=noninteractive

sudo apt-get install salt-master -y
sudo systemctl enable salt-master && sudo systemctl start salt-master
