# NixOS SD-image install & update guide

This README explains how to build the flake sd-image, flash it to an SD card, and update the running device remotely with nixos-rebuild.

## Requirements

- Nix with flakes enabled on your build machine
- SSH access to the target device (root or a user with sudo)
- The flake repository available locally or remotely
- An SD card reader

## Build the SD image

From the flake root:

- Build the sd-image output (replace attribute name if different):
  ```
  nix build .#packages.aarch64-linux.raspi-sika-sd
  ```
- The built image will be under `./result` (e.g. `result/sd-image/nixos-image-sd-card-*.zst`).

- Decompress the image:
  ```
  unzstd result/sd-image/nixos-image-sd-card-*.zst -o ./nixos-image-sd-card.img
  ```

## Flash the SD card

1. Identify your SD device (example: /dev/sdX or /dev/rdiskN). Be careful — this will overwrite the device.
2. Flash with dd (Linux/macOS):

```
sudo dd if=nixos-image-sd-card.img of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

4. Insert the card and boot the device.

## Update the configuration remotely

From a machine with the flake (local checkout) and SSH access to the device:

- To apply a new flake config on the remote device:

```
nixos-rebuild switch --target-host <user>@<DEVICE_IP> --flake ./#raspi-sika --use-remote-sudo --accept-flake-config --log-format internal-json -v |& nom --json
```

## Troubleshooting

- If the remote build fails due to missing Nix on the device, install Nix or build locally and copy the result.
- Use `nix flake show` to find attributes and ensure the correct host name is used.
- Check SSH connectivity: `ssh root@<DEVICE_IP>`

> Note: the onboard led should switch to a heartbeat pattern once the system is running, or a blinking pattern if bar-sika or the network configuration fails.
