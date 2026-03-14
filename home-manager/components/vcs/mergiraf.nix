{
  programs = {
    mergiraf = {
      enable = true;
      enableGitIntegration = true;
      enableJujutsuIntegration = true;
    };
    git.settings.merge.tool = "mergiraf";
    jujutsu.settings.ui.merge-editor = "mergiraf";
  };
}
