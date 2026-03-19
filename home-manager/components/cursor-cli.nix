{
  pkgs,
  isWorkMac,
  ...
}:
if isWorkMac then
  {
    home.packages = [
      # TODO this can be dropped when renamed upstream
      # package was renamed and codecompanion.nvim
      # looks for the new path
      (pkgs.symlinkJoin {
        name = "agent";
        paths = [ pkgs.cursor-cli ];
        postBuild = ''
          ln -s ${pkgs.cursor-cli}/bin/cursor-agent $out/bin/agent
        '';
      })
    ];
    home.file.".cursor/mcp.json".text = builtins.toJSON {
      mcpServers = {
        jira.url = "https://mcp.atlassian.com/v1/mcp";
        notion.url = "https://mcp.notion.com/mcp";
        sourcegraph.url = "https://1password.sourcegraphcloud.com/.api/mcp";
      };
    };
  }
else
  { }
