{
  programs = {
    mergiraf.enable = true;
    git.settings.merge.tool = "mergiraf";
    jujutsu.settings.ui.merge-editor = "mergiraf";
  };
}
