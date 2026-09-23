{
  inputs,
  pkgs,
}:
let
  # Nixpkgs keeps Qt5 KDE Frameworks in this scope after removing its public aliases.
  kf5 = pkgs.libsForQt5.__internalKF5;
  # Build each ABI separately: Nix Qt setup hooks deliberately reject mixed majors.
  qtengineQt5 = pkgs.qtengine.overrideAttrs (old: {
    pname = "qtengine-qt5";
    nativeBuildInputs = old.nativeBuildInputs ++ [ kf5.extra-cmake-modules ];
    buildInputs = [
      pkgs.libsForQt5.qtbase
      kf5.kconfig
      kf5.kconfigwidgets
      kf5.kiconthemes
    ];
    cmakeFlags = [
      "-DBUILD_QT5=ON"
      "-DBUILD_QT6=OFF"
      "-DQT5_PLUGINDIR=${builtins.placeholder "out"}/${pkgs.libsForQt5.qtbase.qtPluginPrefix}"
    ];
  });
  qtenginePackage = pkgs.symlinkJoin {
    name = "qtengine-${pkgs.qtengine.version}";
    paths = [
      qtengineQt5
      pkgs.qtengine
    ];
  };
  darklyQt5 = pkgs.darkly.overrideAttrs (old: {
    pname = "darkly-qt5";
    nativeBuildInputs = builtins.filter (dep: dep != pkgs.qt6.wrapQtAppsHook) old.nativeBuildInputs ++ [
      pkgs.libsForQt5.wrapQtAppsHook
    ];
    buildInputs = [
      pkgs.libsForQt5.qtbase
      pkgs.libsForQt5.qtdeclarative
      kf5.kconfig
      kf5.kconfigwidgets
      kf5.kcoreaddons
      kf5.kguiaddons
      kf5.ki18n
      kf5.kiconthemes
      kf5.kwindowsystem
      kf5.kirigami2
    ];
    cmakeFlags = [
      "-DBUILD_QT5=ON"
      "-DBUILD_QT6=OFF"
      "-DKDE_INSTALL_QTPLUGINDIR=${builtins.placeholder "out"}/${pkgs.libsForQt5.qtbase.qtPluginPrefix}"
    ];
    # Qt5 links ConfigWidgets directly; settings modules and KCMUtils are Qt6-only.
    postPatch = (old.postPatch or "") + ''
      substituteInPlace CMakeLists.txt --replace-fail '
              if(NOT WIN32 AND NOT APPLE)
                  find_package(KF5KCMUtils ''${KF5_MIN_VERSION})
                  set_package_properties(KF5KCMUtils PROPERTIES
                      TYPE REQUIRED
                      DESCRIPTION "Helps create configuration modules"
                      PURPOSE "KCMUtils used for the configuration modules or the decoration and Qt Style"
                  )
              endif()' '
          find_package(KF5ConfigWidgets ''${KF5_MIN_VERSION} REQUIRED)'
    '';
  });
  darklyPackage = pkgs.symlinkJoin {
    name = "darkly-${pkgs.darkly.version}";
    paths = [
      darklyQt5
      pkgs.darkly
    ];
  };
  caelestiaCliPackage =
    inputs.caelestia-shell.inputs.caelestia-cli.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
      (old: {
        # Upstream overrides patchPhase without invoking the postPatch hook.
        patchPhase = old.patchPhase + ''
          # GTK4 themes use the CSS variable; GTK3 only supports named colors.
          substituteInPlace src/caelestia/utils/theme.py \
            --replace-fail 'atomic_write(gtk_config_dir / "gtk.css", gtk_template)' \
              'atomic_write(gtk_config_dir / "gtk.css", gtk_template + ("\n:root { --accent-bg-color: @accent_bg_color; }\n" if gtk_version == "gtk-4.0" else ""))'
          substituteInPlace src/caelestia/data/templates/gtk.css \
            --replace-fail '@define-color theme_selected_fg_color @primary;' \
              '@define-color theme_selected_fg_color @accent_color;'
        '';
      });
  zynixGamesCatalog = pkgs.callPackage ./scripts/zynix-games-catalog.nix { };
  baseCaelestiaPackage =
    inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.caelestia-shell.override
      {
        withCli = true;
        caelestia-cli = caelestiaCliPackage;
        extraRuntimeDeps = with pkgs; [
          tmux
          mpv
          procps
          wl-clipboard
          file
          xdg-utils
          exiftool
          mediainfo
          b3sum
          coreutils
          uwsm
          qt6.qtimageformats
          zynixGamesCatalog
        ];
      };
  caelestiaPackage = baseCaelestiaPackage.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      mkdir -p $out/share/caelestia-shell/modules/zynix
      cp -r ${./qml/modules/zynix}/. $out/share/caelestia-shell/modules/zynix/

      shell_qml="$out/share/caelestia-shell/shell.qml"
      if ! grep -Fq 'import "modules/zynix"' "$shell_qml"; then
        grep -Fq 'import "modules/drawers"' "$shell_qml" || {
          echo "Caelestia shell.qml no longer exposes the drawers import anchor" >&2
          exit 1
        }
        sed -i '/import "modules\/drawers"/a import "modules/zynix"' "$shell_qml"
      fi

      if ! grep -Fq 'ZynixShellExtensions {}' "$shell_qml"; then
        grep -Eq '^[[:space:]]*Background[[:space:]]*\{\}[[:space:]]*$' "$shell_qml" || {
          echo "Caelestia shell.qml no longer exposes the Background anchor" >&2
          exit 1
        }
        sed -i '/^[[:space:]]*Background[[:space:]]*{}[[:space:]]*$/a\          ZynixShellExtensions {}' "$shell_qml"
      fi
    '';
  });
in
{
  inherit
    caelestiaCliPackage
    caelestiaPackage
    qtenginePackage
    darklyPackage
    ;
}
