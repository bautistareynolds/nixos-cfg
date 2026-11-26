# Hyprland session + the system-level pieces a bare compositor needs
# (login screen, portals, polkit, fonts, graphics).
{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Minimal text login screen that launches Hyprland.
  services.greetd = {
    enable = true;
    settings.default_session = {
      user = "greeter";
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd start-hyprland";
    };
  };

  # Polkit agent (password prompts for GUI apps). Exposed under
  # /run/current-system/sw/libexec so hyprland.lua can start it by a stable path.
  security.polkit.enable = true;
  environment.systemPackages = [ pkgs.hyprpolkitagent ];
  environment.pathsToLink = [ "/libexec" ];

  security.pam.services.hyprlock = { }; # hyprlock needs a PAM entry to unlock

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # Chrome/Electron apps run native Wayland

  services.gvfs.enable = true; # trash, mounting USB drives in the file manager
  services.udisks2.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];
}
