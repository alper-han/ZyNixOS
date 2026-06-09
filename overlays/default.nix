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
    {
      # virtualisation.libvirtd.qemu.package uses pkgs.qemu_kvm.
      # Pin qemu_kvm to 10.2.2 because the anti-detection patch is version-specific.
      qemu_kvm =
        let
          qemuPkgs = inputs.nixpkgs-qemu-10-2-2.legacyPackages.${final.stdenv.hostPlatform.system};
        in
        qemuPkgs.qemu_kvm.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [
          (final.fetchpatch {
            url = "https://raw.githubusercontent.com/zhaodice/qemu-anti-detection/2750c86d2d045243ba6617951487e41b25c05557/qemu-10.2.2.patch";
            hash = "sha256-mMUtKzkHh8Q1lBu2Lrok6au521mUf4KOj8QJZRPOCOQ=";
          })
        ];
      });

      vesktop = prev.vesktop.override {
        withTTS = false;
        withSystemVencord = false;
        withMiddleClickScroll = true;
      };
      equibop = prev.equibop.override {
        withTTS = false;
        withMiddleClickScroll = true;
      };
      discord = prev.discord.override {
        withVencord = true;
        withOpenASAR = true;
        enableAutoscroll = true;
      };

      davinci-resolve-studio =
        inputs.nixpkgs-davinci-20-2-3.legacyPackages.${final.stdenv.hostPlatform.system}.davinci-resolve-studio;

      #    nvidia-vaapi-driver = prev.nvidia-vaapi-driver.overrideAttrs (oldAttrs: {
      #      src = /home/zynix/Downloads/encode/nvidia-vaapi-driver;
      #    });
    };
}
