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
        mcp = {
          jira = {
            enabled = true;
            type = "remote";
            url = "https://mcp.atlassian.com/v1/mcp";
          };
          notion = {
            enabled = true;
            type = "remote";
            url = "https://mcp.notion.com/mcp";
          };
          sourcegraph = {
            enabled = true;
            type = "remote";
            url = "https://1password.sourcegraphcloud.com/.api/mcp";
          };
        };
      })
    ];
  };
}
