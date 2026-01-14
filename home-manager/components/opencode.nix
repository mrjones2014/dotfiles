{
  programs.opencode = {
    enable = true;
    settings = {
      theme = "tokyonight";
      enabled_providers = [ "github-copilot" ];
      model = "github-copilot/claude-sonnet-4.5";
      default_agent = "plan";
    };
  };
}
