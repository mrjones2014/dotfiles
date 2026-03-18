{
  pkgs,
  lib,
  isWorkMac,
  ...
}:
{
  home.packages = with pkgs; [
    ast-grep
    fd
    jq
    parallel
    ripgrep
    sd
    yq-go
  ];
  programs.claude-code = lib.mkMerge [
    {
      enable = true;
      settings = {
        # do not ever commit anything on my behalf
        includeGitInstructions = false;
        attribution = {
          commit = "";
          pr = "";
        };
        spinnerTipsEnabled = false;
        feedbackSurveyRate = 0;
        permissions = {
          defaultMode = "plan";
        };
      };
    }
    (lib.mkIf isWorkMac {
      mcpServers = {
        jira = {
          url = "https://mcp.atlassian.com/v1/mcp";
          type = "http";
        };
        notion = {
          url = "https://mcp.notion.com/mcp";
          type = "http";
        };
        sourcegraph = {
          url = "https://1password.sourcegraphcloud.com/.api/mcp";
          type = "http";
        };
      };
    })
  ];
}
