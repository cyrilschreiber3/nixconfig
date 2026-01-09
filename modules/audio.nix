{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    alsa-utils
    alsa-lib
  ];

  security.rtkit.enable = true;

  services.pulseaudio = {
    enable = true;
    support32Bit = true;
  };

  services.pipewire = {
    enable = false;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.alsa.config = ''
    pcm.!default {
            type plug
            slave.pcm "dmixer"
        }

        pcm.dmixer {
            type dmix
            ipc_key 1024
            slave {
                pcm "hw:1,0"
                period_time 0
                period_size 1024
                buffer_size 4096
                rate 48000
            }
            bindings {
                0 0
                1 1
            }
        }

        ctl.!default {
            type hw
            card 1
        }
  '';
}
