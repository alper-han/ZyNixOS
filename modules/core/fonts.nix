{ pkgs, ... }:
{
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      maple-mono.NF
      pkgs.nerd-fonts.jetbrains-mono

      noto-fonts
      noto-fonts-color-emoji

      font-awesome
    ];
    fontconfig = {
      enable = true;
      antialias = true;
      defaultFonts = {
        monospace = [
          "JetBrainsMono Nerd Font"
          "Maple Mono NF"
          "Noto Mono"
          "DejaVu Sans Mono"
        ];
        sansSerif = [
          "Noto Sans"
          "Font Awesome 6 Free"
          "Adwaita Sans"
          "DejaVu Sans"
        ];
        serif = [
          "Noto Serif"
          "DejaVu Serif"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
