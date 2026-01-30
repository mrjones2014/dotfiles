{
  lib,
  isWorkMac,
  ...
}:
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
        enabled_providers = [
          "github-copilot"
          "cursor"
        ];
        model = "cursor/opus-4.5-thinking";
        plugin = [ "yet-another-opencode-cursor-auth" ];
        provider.cursor.name = "Cursor";
      })
    ];
  };
}
