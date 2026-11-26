# Boot, nix itself, locale, networking, the user account.
{ pkgs, ... }:
{
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;
    efi.canTouchEfiVariables = true;
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
  nixpkgs.config.allowUnfree = true; # chrome, spotify

  networking.networkmanager.enable = true;

  time.timeZone = "America/Argentina/Buenos_Aires";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "la-latin1";

  users.users.sun = {
    isNormalUser = true;
    description = "sun";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
  };

  # Bare minimum system-wide; user apps live in home/sun.
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    unzip
  ];

  programs.dconf.enable = true; # GTK apps store settings here
  services.fwupd.enable = true; # firmware updates
}
