{ pkgs, ... }:
{
  home-manager.sharedModules = [
    {
      programs.bash = {
        enable = true;
        enableCompletion = true;
        historyFileSize = 100000;
        shellOptions = [
          "autocd"
          "cdspell"
          "cmdhist"
          "dotglob"
          "histappend"
          "expand_aliases"
          "checkwinsize"
        ];
        shellAliases = {
          nf = "${pkgs.microfetch}/bin/microfetch";
          ff = "${pkgs.fastfetch}/bin/fastfetch";
        };
      };
    }
  ];
}
