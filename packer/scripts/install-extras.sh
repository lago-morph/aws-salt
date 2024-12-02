#!/bin/bash
#
export DEBIAN_FRONTEND=noninteractive

sudo apt-get install jq awscli -y
sudo apt-get install pipx python3-venv -y
pipx install jinja2-cli --force
pipx ensurepath
