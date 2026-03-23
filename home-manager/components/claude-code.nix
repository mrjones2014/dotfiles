{
  pkgs,
  lib,
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
        permissions.defaultMode = "plan";
        model = "opus";
      };
    }
  ];
}
