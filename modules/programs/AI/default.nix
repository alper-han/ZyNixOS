{ pkgs, inputs, ... }:
{
  environment.sessionVariables = {
    RTK_TELEMETRY_DISABLED = "1";
    OMO_SEND_ANONYMOUS_TELEMETRY = "0";
    OMO_DISABLE_POSTHOG = "1";
    DOTNET_ROOT = "${pkgs.dotnet-sdk_10}/share/dotnet";
    DOTNET_ROOT_X64 = "${pkgs.dotnet-sdk_10}/share/dotnet";
  };

  environment.systemPackages = with pkgs; [
    nodejs
    # bun
    # python3
    # python3Packages.pip
    # code-cursor
    # antigravity-fhs
    # claude-code
    opencode
    # rtk
    inputs.serena.packages.${pkgs.stdenv.hostPlatform.system}.default
    # opencode-desktop
    # codex
    # nixd
  ];

  # imports = [ ./ollama.nix ];

#  home-manager.sharedModules = [
#    (_: {
#      home.file.".local/bin/oh-my-openagent" = {
#        executable = true;
#        text = ''
#          #!${pkgs.runtimeShell}
#          exec ${pkgs.bun}/bin/bun "$HOME/.config/opencode/node_modules/oh-my-openagent/dist/cli/index.js" "$@"
#        '';
#      };
#
#      home.file.".local/bin/oh-my-opencode" = {
#        executable = true;
#        text = ''
#          #!${pkgs.runtimeShell}
#          exec ${pkgs.bun}/bin/bun "$HOME/.config/opencode/node_modules/oh-my-opencode/dist/cli/index.js" "$@"
#        '';
#      };
#    })
#  ];
}
