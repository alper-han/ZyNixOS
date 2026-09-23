{
  config,
  pkgs,
  lib,
  inputs,
  host,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix)
    username
    editor
    terminal
    shell
    ;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  assertions = [
    {
      assertion = config.users.mutableUsers;
      message = "Keep users.mutableUsers = true to preserve passwd-managed passwords and prevent account lockout.";
    }
    {
      assertion = lib.all (attribute: config.users.users.${username}.${attribute} == null) [
        "password"
        "hashedPassword"
        "hashedPasswordFile"
        "initialPassword"
        "initialHashedPassword"
      ];
      message = "Keep password, hashedPassword, hashedPasswordFile, initialPassword, and initialHashedPassword null for users.users.${username}; use passwd to change its password safely.";
    }
  ];
  programs.dconf.enable = true;
  programs.${shell} = {
    enable = true;
  }
  // lib.optionalAttrs (shell == "zsh") {
    enableGlobalCompInit = false; # Home Manager owns Zsh compinit.
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    overwriteBackup = false;
    backupFileExtension = "backup";
    users.${username} = {
      programs.home-manager.enable = true;
      xdg.enable = true;

      home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "26.11"; # Do not change!
        sessionVariables = {
          EDITOR =
            if (editor == "nixvim" || editor == "neovim" || editor == "nvchad") then
              "nvim"
            else if editor == "vscode" then
              "code"
            else if editor == "kate" then
              "kate"
            else if editor == "kwrite" then
              "kwrite"
            else if editor == "gedit" then
              "gedit"
            else
              "nano";
          BROWSER = "zen-beta";
          TERMINAL = "${terminal}";
        };
      };
    };
  };
  users = {
    # Preserve passwords changed with passwd across rebuilds.
    mutableUsers = true;
    users.${username} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      shell = pkgs.${shell};
    };
  };
  nix.settings.allowed-users = [ "${username}" ];
}
