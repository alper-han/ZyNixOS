{
  pkgs,
  lib,
  host,
  ...
}:
let
  inherit (import ../../../../../hosts/${host}/variables.nix) terminal;
  inherit (lib) getExe;
  mkRofiImage =
    name: hash: {
      inherit name;
      path = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/adi1090x/rofi/master/files/images/${name}";
        inherit hash;
      };
    };
  rofiImages = pkgs.linkFarm "rofi-images" [
    (mkRofiImage "paper.png" "sha256-meBjjafWiB6qRfck3oNAix0TgLRZb8UKBJ2qrMzOK6o=")
    (mkRofiImage "gradient.png" "sha256-n3IogwT1UCc8WtLUq2wMZ/VqFKDi+8OSozRZE7w4sTo=")
    (mkRofiImage "flowers-1.png" "sha256-O2MfdVBseuVdLbIYhyCP5dWvDWs9jAFGaiG5zPJxcwM=")
    (mkRofiImage "flowers-2.png" "sha256-xwTNrO+Rvcs7DwUkTV+PpvaKPqTEIuhlvE9KUtTpTj8=")
    (mkRofiImage "flowers-3.png" "sha256-sj30LovmxDoJj2nXUl+NZvj+hdStD9Qruvj8S3AobF0=")
    (mkRofiImage "a.png" "sha256-zFMVr4xEnIwloFNQAPjbi9mkgdzrLzcfxNQn+5eLNz0=")
    (mkRofiImage "b.png" "sha256-U/UR0LfIa5hY2bNmj02T890vMO0hk03/gVfuMMwXFmk=")
    (mkRofiImage "c.png" "sha256-Hw52N0KsyKxTxhzeSgIUb6AU310t1DsxV1oJQ9i7VRM=")
    (mkRofiImage "d.png" "sha256-V4VkcJ2ergPd5RAD0WKj99TsCaKK8Uz884Z9ftCXsck=")
    (mkRofiImage "e.jpg" "sha256-KyA/KpARKAF8XQWmGnOnJLkXM1/pT39DGjguZz4AZcw=")
    (mkRofiImage "f.png" "sha256-LxNabcZC2ZaB9t7nxCjgNx5mAn5yQSFjski/GG0e9F8=")
    (mkRofiImage "g.png" "sha256-nqUuZS7nVNuPlRkpDNcPcyXgFPVN4ftV20mqz3JaY5g=")
    (mkRofiImage "h.jpg" "sha256-4yTJVoN0a0/ptzXMiESH5NvfG6heFULA9MmVq2s4LL4=")
    (mkRofiImage "i.jpg" "sha256-AI+LmD0GtJAYdx8ninUv/hypqF44I4+xsU3TIVh0xWs=")
    (mkRofiImage "j.jpg" "sha256-xQSJM9qojTBAtbnJIhxa6X3zsb5I1UmxQn9A6TbC9II=")
  ];
in
{
  home-manager.sharedModules = [
    (_: {
      programs.rofi = {
        enable = true;
        terminal = "uwsm app -- ${getExe pkgs.${terminal}}";
        plugins = with pkgs; [
          rofi-emoji # https://github.com/Mange/rofi-emoji 🤯
          rofi-games # https://github.com/Rolv-Apneseth/rofi-games 🎮
        ];
        extraConfig = import ./config.nix;
      };
      xdg.configFile."rofi/launchers" = {
        source = ./launchers;
        recursive = true;
      };
      xdg.configFile."rofi/colors" = {
        source = ./colors;
        recursive = true;
      };
      xdg.configFile."rofi/images" = {
        source = rofiImages;
        recursive = true;
      };
    })
  ];
}
