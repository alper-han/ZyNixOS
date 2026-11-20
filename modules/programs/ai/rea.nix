{ pkgs, ... }:
{
  environment.sessionVariables = {
    GHIDRA_INSTALL_DIR = "${pkgs.ghidra}/lib/ghidra";
  };

  environment.systemPackages = with pkgs; [
    # Reverse engineering engines & analysis tools for REA (Reverse Engineer Anything)
    ghidra # bundles its own JDK; includes analyzeHeadless
    # openjdk21
    # jadx
    # apktool
    # wireshark-cli
    # rizin
    # binwalk
    # android-tools # also in modules/core/packages.nix
  ];
}
