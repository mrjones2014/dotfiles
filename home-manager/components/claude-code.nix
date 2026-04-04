{
  inputs,
  pkgs,
  isWorkMac,
  ...
}:
{
  home.sessionVariables = {
    DISABLE_TELEMETRY = "1";
    OTEL_METRICS_EXPORTER = "";
    CLAUDE_CODE_ENABLE_TELEMETRY = "0";
    CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
  };
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
    # TODO remove: https://nixpkgs-tracker.ocfox.me/?pr=505911
    package = inputs.claude-code.packages.${pkgs.stdenv.system}.default;
    skillsDir = ../../agent/skills;
    rulesDir = ../../agent/rules;
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
      model = if isWorkMac then "opus[1m]" else "opus";
      spinnerTipsEnabled = false;
      spinnerTipsOverride = {
        excludeDefault = true;
        tips = [ ];
      };
      spinnerVerbs = {
        mode = "replace";
        verbs = [ "Processing" ];
      };
      # Do not exit plan mode yourself, I will enter
      # build mode only AFTER the plan is reviewed
      permissions.deny = [ "ExitPlanMode" ];
    };
  };
}
