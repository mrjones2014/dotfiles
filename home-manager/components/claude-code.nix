{ pkgs, ... }:
{
  home.sessionVariables.DISABLE_TELEMETRY = "1";
  home.packages = with pkgs; [
    ast-grep
    fd
    jq
    parallel
    ripgrep
    sd
    yq-go
  ];
  programs.claude-code = {
    enable = true;
    skillsDir = ../../agent/skills;
    # some settings are undocumented, refer to the schema
    # https://www.schemastore.org/claude-code-settings.json
    settings = {
      # do not ever commit anything on my behalf
      includeGitInstructions = false;
      attribution = {
        commit = "";
        pr = "";
      };
      feedbackSurveyRate = 0;
      permissions.defaultMode = "plan";
      model = "opus";
      spinnerTipsEnabled = false;
      spinnerTipsOverride = {
        excludeDefault = true;
        tips = [ ];
      };
      spinnerVerbs = {
        mode = "replace";
        verbs = [ "Processing" ];
      };
    };
  };
}
