{ lib, isWorkMac, ... }:
{
  programs.opencode = {
    enable = true;
    settings = lib.mkMerge [
      {
        theme = "tokyonight";
        default_agent = "plan";
      }
      (lib.mkIf isWorkMac {
        # Use only compliant providers on work machine
        enabled_providers = [ "github-copilot" ];
        model = "github-copilot/claude-sonnet-4.5";
      })
    ];
  };
}
