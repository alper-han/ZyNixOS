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
      libx11
      libxcursor
      libxrandr
      libxext
      libxi
      libice
      libsm
      libxcomposite
      libxtst
      libxdamage
      libxfixes
      libxcb
      libxshmfence
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
