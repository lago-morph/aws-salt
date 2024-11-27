#!/bin/bash
#
sudo apt-get install salt-master -y
sudo systemctl enable salt-master && sudo systemctl start salt-master
