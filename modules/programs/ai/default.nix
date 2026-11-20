{ ... }:
{
  imports = [
    ./packages.nix
    ./lsp.nix
    ./dap.nix
    ./omp.nix
    ./superpowers.nix
    ./ui-ux-pro-max.nix
    # ./security-skills.nix
    # ./reverse-skill.nix
    ./rea.nix

    # Optional Ollama service; configure its model policy before enabling.
    # ./ollama.nix
  ];
}
