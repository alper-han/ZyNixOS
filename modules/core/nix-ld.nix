{ pkgs, ... }:
{
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
      icu
      fuse3
      nss
      nspr
      curl
      expat
      libuuid
      udev
      alsa-lib
      fontconfig
      freetype
      glew
      libglvnd
      vulkan-loader
      
      # Xorg & GUI
      xorg.libX11
      xorg.libXcursor
      xorg.libXrandr
      xorg.libXext
      xorg.libXi
      xorg.libICE
      xorg.libSM
      xorg.libXcomposite
      xorg.libXtst
      xorg.libXdamage
      xorg.libXfixes
      xorg.libxcb
      xorg.libxshmfence
      gtk3
      glib
      cairo
      pango
      mesa
      at-spi2-atk
      cups
      dbus
      libdrm
      libxkbcommon
      libxml2
      systemd
    ];
  };
}
