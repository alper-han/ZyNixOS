{ ... }:
{
  imports = [
    ./packages.nix
    ./lsp.nix
    ./dap.nix
    ./omp.nix
    ./superpowers.nix
    ./ui-ux-pro-max.nix

    # Optional Ollama service; configure its model policy before enabling.
    # ./ollama.nix
  ];
}
