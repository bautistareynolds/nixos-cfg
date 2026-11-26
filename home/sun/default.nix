# User environment for sun: apps, and links to the hand-written dotfiles.
{ config, pkgs, ... }:
let
  # Dotfiles are linked straight from the repo (not copied into the nix store),
  # so you can edit them and reload live, and they're still tracked in git.
  repo = "${config.home.homeDirectory}/nixos-cfg";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/dotfiles/${path}";
in
{
  home.username = "sun";
  home.homeDirectory = "/home/sun";
  home.stateVersion = "26.05";

  xdg.configFile = {
    "hypr".source = link "hypr";
    "waybar".source = link "waybar";
    "xkb".source = link "xkb"; # custom keyboard options (caps lock fix)
  };

  home.packages = with pkgs; [
    # dev
    python314
    nodejs_latest
    go
    zed-editor
    nil # nix language server (for zed)
    nixfmt

    # apps
    google-chrome
    qbittorrent
    spotify
    mpv
    ffmpeg
    yt-dlp
    _7zz

    # desktop plumbing (Hyprland doesn't ship these)
    kitty # terminal
    fuzzel # app launcher
    waybar # bar
    mako # notifications
    hyprlock # lock screen
    hypridle # idle -> lock/screen off
    wl-clipboard
    cliphist # clipboard history
    grim # screenshots
    slurp # region selection
    brightnessctl
    playerctl
    pavucontrol # audio mixer
    networkmanagerapplet # wifi tray icon
    thunar # file manager
    nwg-look # GTK theme picker
    adwaita-icon-theme

    # system tools
    mission-center # task manager (GUI)
    btop # task manager (terminal)
    overskride # bluetooth (GUI)
    bluetui # bluetooth (terminal)
    fastfetch
  ];

  programs.firefox.enable = true;

  programs.git = {
    enable = true;
    settings = {
      # user.name = "...";
      # user.email = "...";
      init.defaultBranch = "main";
    };
  };

  # Dark mode for GTK / libadwaita apps.
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  programs.home-manager.enable = true;
}
