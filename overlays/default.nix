{ host, inputs, ... }:
{
  # Overlay custom derivations into nixpkgs so you can use pkgs.<name>
  additions =
    final: _prev:
    import ../pkgs {
      pkgs = final;
      inherit host;
    };

  # https://wiki.nixos.org/wiki/Overlays
  modifications =
    final: prev:
    let
      nixpkgsWithDiscordKrisp = prev.applyPatches {
        name = "nixpkgs-pr-506089-discord-krisp";
        src = prev.path;
        patches = [
          (prev.fetchpatch {
            url = "https://github.com/NixOS/nixpkgs/commit/57844013458b550400c5bb3b98ae35267fc5ee44.patch";
            hash = "sha256-zDNXE0nbeoV4lJF2wTIEdzkujIfBZBj6Anya8apUCJc=";
          })
        ];
      };

      discordKrispPkgs = import nixpkgsWithDiscordKrisp {
        system = final.stdenv.hostPlatform.system;
        config = prev.config;
      };
    in
    {
      stable = import inputs.nixpkgs-stable {
        system = final.stdenv.hostPlatform.system;
      };

      vesktop = prev.vesktop.override {
        withTTS = false;
        withSystemVencord = false;
        withMiddleClickScroll = true;
      };
      equibop = prev.equibop.override {
        withTTS = false;
        withMiddleClickScroll = true;
      };
      discord = discordKrispPkgs.discord.override {
        withVencord = true;
        withOpenASAR = true;
        enableAutoscroll = true;
        withKrisp = true;
      };

      davinci-resolve-studio =
        inputs.nixpkgs-davinci-20-2-3.legacyPackages.${final.stdenv.hostPlatform.system}.davinci-resolve-studio;

      #    nvidia-vaapi-driver = prev.nvidia-vaapi-driver.overrideAttrs (oldAttrs: {
      #      src = /home/zynix/Downloads/encode/nvidia-vaapi-driver;
      #    });
    };
}
