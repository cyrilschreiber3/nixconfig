#! /usr/bin/env bash

set -e

# NVME ssd is bound to VFIO when VM starts
sudo echo "0000:40:00.0" >/sys/bus/pci/drivers/nvme/unbind
sudo echo "vfio-pci" >/sys/bus/pci/devices/0000:40:00.0/driver_override
sudo echo "0000:40:00.0" >/sys/bus/pci/drivers/vfio-pci/bind
