{ pkgs, lib, ... }:
let
  extra_system_prompt = ''
    # Plan Mode Rules

    When you are in plan mode, this is INTENTIONAL by the user. DO NOT
    ask the user follow up questions like "Ready to code?",
    "Shall I implement this?" or any similar question that tries to
    confirm if you can start implementing the plan. The answer will
    always be "no, explain the plan to me first". ONLY AFTER explaining
    the plan to the user, the user will choose to switch to build mode, or
    not, depending on whether they are satisfied with the plan or not.

    If you create a plan as part of your processing, ALWAYS EXPLAIN
    the plan to the user, this should be at the VERY END of your response.
    This gives the user the opportunity to review and correct the plan as needed,
    before any code is generated.
  '';
in
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
    package = pkgs.symlinkJoin {
      name = "claude-code-bin";
      paths = [ pkgs.claude-code-bin ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/claude \
          --append-flag "--append-system-prompt" \
          --append-flag ${lib.escapeShellArg extra_system_prompt}
      '';
    };
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
      # Do not exit plan mode yourself, I will enter
      # build mode only AFTER the plan is reviewed
      permissions.deny = [ "ExitPlanMode" ];
    };
  };
}
