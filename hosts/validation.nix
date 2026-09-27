{ host, lib, ... }:
let
  vars = import ./${host}/variables.nix;
in
{
  assertions = [
    {
      assertion = vars ? username && builtins.isString vars.username && vars.username != "";
      message = "username is missing or empty in hosts/${host}/variables.nix.";
    }
    {
      assertion = vars ? hostname && builtins.isString vars.hostname && vars.hostname != "";
      message = "hostname is missing or empty in hosts/${host}/variables.nix.";
    }
    {
      assertion =
        vars ? terminal
        && builtins.elem vars.terminal [
          "kitty"
          "alacritty"
          "none"
        ];
      message = "Invalid or missing terminal '${vars.terminal or ""}' in hosts/${host}/variables.nix. Expected: kitty, alacritty, or none.";
    }
    {
      assertion =
        vars ? editor
        && builtins.elem vars.editor [
          "vscode"
          "kate"
          "none"
        ];
      message = "Invalid or missing editor '${vars.editor or ""}' in hosts/${host}/variables.nix. Expected: vscode, kate, or none.";
    }
    {
      assertion =
        vars ? fileManager
        && builtins.elem vars.fileManager [
          "thunar"
          "yazi"
          "none"
        ];
      message = "Invalid or missing fileManager '${vars.fileManager or ""}' in hosts/${host}/variables.nix. Expected: thunar, yazi, or none.";
    }
    {
      assertion =
        vars ? displayManager
        && builtins.elem vars.displayManager [
          "sddm"
          "greetd"
          "none"
        ];
      message = "Invalid or missing displayManager '${vars.displayManager or ""}' in hosts/${host}/variables.nix. Expected: sddm, greetd, or none.";
    }
    {
      assertion =
        vars ? shell
        && builtins.elem vars.shell [
          "bash"
          "zsh"
        ];
      message = "Invalid or missing shell '${vars.shell or ""}' in hosts/${host}/variables.nix. Expected: bash or zsh.";
    }
    {
      assertion =
        vars ? videoDriver
        && builtins.elem vars.videoDriver [
          "nvidia"
          "amdgpu"
          "intel"
          "none"
        ];
      message = "Invalid or missing videoDriver '${vars.videoDriver or ""}' in hosts/${host}/variables.nix. Expected: nvidia, amdgpu, intel, or none.";
    }
    {
      assertion =
        vars ? powerManager
        && builtins.elem vars.powerManager [
          "cpufreq"
          "tlp"
          "none"
        ];
      message = "Invalid or missing powerManager '${vars.powerManager or ""}' in hosts/${host}/variables.nix. Expected: cpufreq, tlp, or none.";
    }
    {
      assertion =
        vars ? sddmTheme
        && builtins.elem vars.sddmTheme [
          "astronaut"
          "black_hole"
          "purple_leaves"
        ];
      message = "Invalid or missing sddmTheme '${vars.sddmTheme or ""}' in hosts/${host}/variables.nix. Expected: astronaut, black_hole, or purple_leaves.";
    }
    {
      assertion = vars ? isLaptop && builtins.isBool vars.isLaptop;
      message = "isLaptop must be a boolean in hosts/${host}/variables.nix.";
    }
    {
      assertion = vars ? bluetoothSupport && builtins.isBool vars.bluetoothSupport;
      message = "bluetoothSupport must be a boolean in hosts/${host}/variables.nix.";
    }
  ];
}
