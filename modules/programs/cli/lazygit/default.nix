{ ... }:
{
  home-manager.sharedModules = [
    (_: {
      home.shellAliases = {
        lg = "lazygit";
      };
      programs.lazygit = {
        enable = true;
        settings = {
          gui = {
            authorColors = {
              "*" = "#b4befe";
            };
            theme = {
              activeBorderColor = [
                "#89b4fa"
                "bold"
              ];
              inactiveBorderColor = [ "#a6adc8" ];
              optionsTextColor = [ "#89b4fa" ];
              selectedLineBgColor = [ "#313244" ];
              cherryPickedCommitBgColor = [ "#45475a" ];
              cherryPickedCommitFgColor = [ "#89b4fa" ];
              unstagedChangesColor = [ "#f38ba8" ];
              defaultFgColor = [ "#cdd6f4" ];
              searchingActiveBorderColor = [ "#f9e2af" ];
            };
          };
          git = {
            overrideGpg = true;
          };
        };
      };
    })
  ];
}
