# nixos-cfg

NixOS 26.05 + Hyprland 0.55, flake + Home Manager.

## Layout

```
flake.nix                      inputs (nixpkgs 26.05, home-manager) + the one host
hosts/nixos-desktop/           machine-specific: hostname, GPU, hardware-configuration.nix
modules/nixos/                 system modules, one concern per file
  core.nix                     boot, nix settings, locale, network, user
  audio.nix                    pipewire
  bluetooth.nix                bluez (+ controller pairing fix)
  hyprland.nix                 hyprland, greetd login, polkit, portals, fonts
home/sun/default.nix           user apps + links dotfiles into ~/.config
dotfiles/                      plain config files, edited directly
  hypr/                        hyprland.lua, hyprlock.conf, hypridle.conf
  waybar/                      config.jsonc, style.css
  xkb/                         custom keyboard option (caps lock fix)
```

**Rule of thumb:** *what is installed* → Nix. *How it looks/behaves* → `dotfiles/`.
Dotfiles are symlinked out of the repo (`mkOutOfStoreSymlink`), so editing them takes
effect immediately (no rebuild), and git still tracks every change.

The repo must live at `~/nixos-cfg` for those links to resolve.

## Install

1. Boot the USB (F8 on ASUS boards for the boot menu). Disable Secure Boot in BIOS if it won't boot.
2. In the graphical installer:
   - Keyboard: Latin American. Timezone: Buenos Aires.
   - User **sun**, hostname **nixos-desktop**.
   - Desktop: **No desktop** (Hyprland comes from this config).
   - Allow unfree software: yes.
   - Partitions: **Erase disk** on the 1 TB Kingston NVMe (Windows goes away here).
     Swap: **No swap**. Filesystem: **ext4**. Swap is an 8 GB file set in `hosts/nixos-desktop/default.nix`.
3. Reboot, log in on the text console as `sun`, then:

```sh
nix-shell -p git
git clone https://github.com/bautistareynolds/nixos-cfg ~/nixos-cfg
cp /etc/nixos/hardware-configuration.nix ~/nixos-cfg/hosts/nixos-desktop/
cd ~/nixos-cfg
git add -A          # flakes only see files git knows about!
sudo env NIX_CONFIG="experimental-features = nix-command flakes" \
  nixos-rebuild switch --flake ~/nixos-cfg#nixos-desktop
reboot
```

You land on a text login (tuigreet) that starts Hyprland.

## Day to day

```sh
cd ~/nixos-cfg
nrs                                                  # apply nix changes (alias for nixos-rebuild switch)
nix flake update && sudo nixos-rebuild switch --flake .#nixos-desktop   # update everything
nix fmt                                              # format .nix files
git add -A && git commit -m "..."                    # commit after every working change
```

Broke something? Pick an older generation in the boot menu, or
`sudo nixos-rebuild switch --rollback`.

## Keybinds (SUPER = Windows key)

| Keys | Action |
| --- | --- |
| SUPER+Q / R / E | terminal / launcher / file manager |
| SUPER+C | close window |
| SUPER+F / V | fullscreen / float |
| SUPER+L | lock |
| SUPER+SHIFT+V | clipboard history |
| Print / SHIFT+Print | region → clipboard / full screen → ~/Pictures/Screenshots |
| SUPER+1..0 (+SHIFT) | go to / move window to workspace |
| SUPER+M | exit Hyprland |
| Alt+Shift | switch keyboard layout (latam ↔ us) |

## Tools

- Task manager: `mission-center` (GUI, click CPU/RAM in waybar), `btop` (terminal)
- Bluetooth: `overskride` (GUI, click BT icon in waybar), `bluetui` (terminal)
- Audio: `pavucontrol` (click volume in waybar)

## Caps Lock "HEllo" fix

Stock XKB turns Caps Lock **off on key release**, so if the next letter goes down before
Caps comes up, it's still uppercase. libxkbcommon ≥ 1.11 added `unlockOnPress`; the
`custom:caps_unlock_on_press` option in `dotfiles/xkb/` turns it on, and `hyprland.lua`
enables it. Only works in the Hyprland session (not the TTY/login screen).
Check it loaded: `hyprctl devices` should list the option, and typing fast should give "Hello".
