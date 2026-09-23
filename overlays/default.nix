{
  # Runs after nix-cachyos-kernel so local overrides take precedence.
  modifications = _final: prev: {
    vesktop = prev.vesktop.override {
      withTTS = false;
      withSystemVencord = false;
      withMiddleClickScroll = true;
    };
    discord = prev.discord.override {
      withVencord = true;
      withOpenASAR = false;
      enableAutoscroll = true;
    };
  };
}
