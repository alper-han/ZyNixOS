{
  # User Configuration
  username = "zynix"; # Your username (auto-set with install.sh, live-install.sh, rebuild)
  desktop = "hyprland"; # Options: hyprland, plasma6, gnome
  terminal = "kitty"; # Options: kitty, alacritty
  editor = "kate"; # Options:  vscode, kate, kwrite, gedit
  browser = "zen-beta"; # Options: firefox, floorp, zen-beta
  fileManager = "thunar"; # Options: thunar, yazi, lf
  bar = "caelestia-shell"; # Options: waybar, caelestia-shell
  displayManager = "greetd"; # Options: sddm, greetd
  sddmTheme = "purple_leaves"; # Options: astronaut, black_hole, purple_leaves, jake_the_dog, hyprland_kath
  defaultWallpaper = "evening-sky.jpg"; # SUPER+SHIFT+W is only enabled when bar != "caelestia-shell"
  hyprlockWallpaper = "dark-forest.jpg"; # See modules/themes/wallpapers for options
  shell = "zsh"; # Options: zsh, bash
  games = true; # Whether to enable the gaming module

  # Hardware Configuration
  videoDriver = "nvidia"; # CRITICAL: Choose your GPU driver (nvidia, amdgpu, intel)
  bluetoothSupport = true; # Whether your motherboard supports bluetooth
  hostname = "NixOS"; # Your system hostname
  isLaptop = false; # Set to true for laptops (enables power management)
  powerManager = "cpufreq"; # Options: "cpufreq", "tlp", "none" (only works when isLaptop = true)

  # Localization
  locale = "en_US.UTF-8"; # System locale
  timezone = "Europe/Istanbul"; # Your timezone
  kbdLayout = "tr"; # Keyboard layout
  kbdVariant = ""; # Keyboard variant (can be empty)
  consoleKeymap = "trq"; # TTY keymap
}
