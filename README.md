# ZyNixOS

An x86_64 NixOS flake for UEFI systems, built around Hyprland, Caelestia Shell, and Catppuccin Mocha/Mauve.

## Screenshots

<table>
  <tr>
    <td><img src=".github/screenshots/1.png" alt="ZyNixOS desktop screenshot 1" width="100%"></td>
    <td><img src=".github/screenshots/2.png" alt="ZyNixOS desktop screenshot 2" width="100%"></td>
  </tr>
  <tr>
    <td><img src=".github/screenshots/3.png" alt="ZyNixOS desktop screenshot 3" width="100%"></td>
    <td><img src=".github/screenshots/4.png" alt="ZyNixOS desktop screenshot 4" width="100%"></td>
  </tr>
</table>

<p align="center">
  <img src=".github/screenshots/5.png" alt="SDDM login screen" width="80%">
</p>

## Hosts

The flake defines `Default`, `Desktop`, and `Laptop`. `Default` is the starting point for new hosts; hardware configuration files are machine-specific and must not be reused on another machine.

## Install

```sh
git clone https://github.com/alper-han/ZyNixOS.git
cd ZyNixOS
./install.sh
```

On a NixOS live ISO, review the selected disks and partition plan before confirming; installation can erase data.

## Rebuild

On an installed system, run `rebuild` to apply its configured host. Use `list-gens` and `rollback <generation>` to manage system generations.

Based on [Sly-Harvey/NixOS](https://github.com/Sly-Harvey/NixOS) · [MIT License](LICENSE)
