# Machine-specific bits for the Ryzen 7600X / RX 6900 XT desktop.
# Anything reusable lives in ../../modules/nixos.
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  networking.hostName = "nixos-desktop";

  # AMD GPU: load amdgpu early so the console/greeter come up at native resolution.
  hardware.amdgpu.initrd.enable = true;

  # Swap as a file instead of a partition (install with "No swap").
  # NixOS creates it on first boot; change size freely later. Size is in MiB.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
    }
  ];

  # Set once at install time; don't change it on upgrades. See `man configuration.nix`.
  system.stateVersion = "26.05";
}
