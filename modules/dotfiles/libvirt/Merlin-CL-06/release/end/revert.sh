#! /usr/bin/env bash

set -e

# Device is returned to host when VM stops
sudo echo "0000:40:00.0" >/sys/bus/pci/drivers/vfio-pci/unbind
sudo echo "" >/sys/bus/pci/devices/0000:40:00.0/driver_override
sudo echo "0000:40:00.0" >/sys/bus/pci/drivers/nvme/bind
