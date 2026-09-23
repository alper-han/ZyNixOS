{
  # User
  username = "zynix";
  terminal = "kitty"; # Options: kitty, alacritty
  editor = "kate"; # Options: vscode, kate
  fileManager = "thunar"; # Options: thunar, yazi
  bar = "caelestia-shell"; # Options: waybar, caelestia-shell
  displayManager = "sddm"; # Options: sddm, greetd
  sddmTheme = "purple_leaves"; # Options: astronaut, black_hole, purple_leaves
  defaultWallpaper = "evening-sky.jpg";
  shell = "zsh"; # Options: zsh, bash
  games = true;

  # Hardware
  videoDriver = "nvidia"; # Options: nvidia, amdgpu, intel
  bluetoothSupport = true;
  hostname = "Default";
  isLaptop = false; # Enables laptop power management when true
  powerManager = "cpufreq"; # Options: cpufreq, tlp, none (used on laptops)

  # Localization
  locale = "en_US.UTF-8";
  timezone = "Europe/Istanbul";
  kbdLayout = "tr";
  kbdVariant = "";
  consoleKeymap = "trq";
}