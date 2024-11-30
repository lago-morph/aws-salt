#!/bin/bash
echo "Waiting for cloud-init starting at $(date)"
sudo cloud-init status --wait
echo "cloud-init done at $(date)"
