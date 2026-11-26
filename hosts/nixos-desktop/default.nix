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

  # Set once at install time; don't change it on upgrades. See `man configuration.nix`.
  system.stateVersion = "26.05";
}
