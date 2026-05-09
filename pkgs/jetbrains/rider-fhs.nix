{
  pkgs,
  lib,
  extraTargetPkgs ? (_: [ ]),
  ...
}:
let
  product = pkgs.jetbrains.rider;
in
pkgs.buildFHSEnv {
  pname = "rider-fhs";
  version = product.version;

  targetPkgs =
    hostPkgs:
    (with hostPkgs; [
      glibc
      udev
      alsa-lib
      fontconfig
      freetype
      glew
      curl
      icu
      libunwind
      libuuid
      lttng-ust
      openssl
      zlib
      krb5
      glib
      nspr
      nss
      dbus
      gtk3
      cairo
      pango
      atk
      gdk-pixbuf
      mesa
      libglvnd
      libdrm
      libxkbcommon
      cups
      expat
      systemd
      vulkan-loader
      libx11
      libice
      libsm
      libxi
      libxcursor
      libxext
      libxrandr
      libxrender
      libxfixes
      libxinerama
      libxtst
      libxcb
      libxshmfence
      libxcomposite
      libxdamage
      libxt
    ])
    ++ extraTargetPkgs hostPkgs;

  runScript = "${product}/bin/rider";

  extraInstallCommands = ''
    ln -s "${product}/share" "$out/"
    ln -s "$out/bin/rider-fhs" "$out/bin/rider"
  '';

  meta = product.meta // {
    description = "JetBrains Rider in an FHS environment for native-runtime-heavy development";
    mainProgram = "rider";
  };
}
