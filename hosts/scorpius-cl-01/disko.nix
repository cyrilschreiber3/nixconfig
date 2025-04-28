# Example to create a bios compatible gpt partition
{lib, ...}: {
  disko.devices = {
    disk.main = {
      device = lib.mkDefault "/dev/disk/by-id/nvme-WD_BLACK_SN850X_4000GB_244603801139";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "512M"; # make it bigger for future installations
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              # Set the bootloader to use the main partition for kernel and initrd
              mountpoint = "/boot/efi";
            };
          };
          root = {
            name = "root";
            end = "-32G";
            content = {
              type = "lvm_pv";
              vg = "pool";
            };
          };
          swap = {
            size = "100%";
            content = {
              type = "swap";
              discardPolicy = "both";
              resumeDevice = true; # resume from hiberation from this device
            };
          };
        };
      };
    };
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [
                "defaults"
              ];
            };
          };
        };
      };
    };
  };
}
