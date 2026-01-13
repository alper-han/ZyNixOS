{
  home-manager.sharedModules = [
    (_: {
      programs.fastfetch = {
        enable = true;
      };
      home = {
        file = {
          ".config/fastfetch/config.jsonc".source = ./config.jsonc;
          ".config/fastfetch/pngs" = {
            source = ./pngs;
            recursive = true;
          };
        };
      };
    })
  ];
}
