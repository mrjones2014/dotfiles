{ lib, isDarwin, ... }:
{
  programs.opencode = {
    enable = true;
    settings = lib.mkMerge [
      {
        theme = "tokyonight";
      }
      # ensure only github copilot can be used on work machine
      # for compliance
      (lib.optionalAttrs isDarwin {
        enabled_providers = [ "github-copilot" ];
        disabled_providers = [
          "anthropic"
          "openai"
          "gemini"
          "deepseek"
          "ollama"
        ];
        model = "github-copilot/claude-sonnet-4-5";
        share = "disabled";
      })
    ];
  };
}
