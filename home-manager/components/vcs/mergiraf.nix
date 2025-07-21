{
  programs = {
    mergiraf.enable = true;
    git.extraConfig.merge.tool = "mergiraf";
    jujutsu.settings.merge-editor = "mergiraf";
  };
}
