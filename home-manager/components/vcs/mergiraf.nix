{
  programs = {
    mergiraf.enable = true;
    git.extraConfig.merge.tool = "mergiraf";
    jujutsu.settings.ui.merge-editor = "mergiraf";
  };
}
