{ pkgs, ... }:
{
  services.ollama = {
    enable = true;

    package = pkgs.ollama-cuda;

    host = "127.0.0.1";
    port = 11434;
    openFirewall = false;

    loadModels = [ ];

    environmentVariables = {
      OLLAMA_NO_CLOUD = "1";
      OLLAMA_CONTEXT_LENGTH = "262144";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q4_0";
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_MAX_LOADED_MODELS = "1";
      OLLAMA_MAX_QUEUE = "16";
      OLLAMA_KEEP_ALIVE = "15m";
    };
  };
}
