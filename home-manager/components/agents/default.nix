{
  lib,
  pkgs,
  isWorkMac,
  ...
}:
let
  hooks = {
    UserPromptSubmit = [
      {
        hooks = [
          {
            type = "command";
            command = "echo 'REMEMBER: caveman mode active. Plans, todos, tables, prose all caveman. Only code blocks normal.'";
          }
        ];
      }
    ];
    SessionStart = [
      {
        hooks = [
          {
            type = "command";
            command = "awk '/^---$/{c++;next} c>=2' ${./skills/caveman/SKILL.md}";
          }
        ];
      }
    ];
  };
  skillPreambleScript = pkgs.writeShellScript "skill-preamble" ''
    awk '/^---$/{c++;next} c>=2' ${./skills/caveman/SKILL.md}
  '';
  codexConfigArgs = [
    "--config"
    "hooks.UserPromptSubmit=[{hooks=[{type=\"command\",command=\"echo REMEMBER: caveman mode active. Plans, todos, tables, prose all caveman. Only code blocks normal.\"}]}]"
    "--config"
    "hooks.SessionStart=[{hooks=[{type=\"command\",command=\"${skillPreambleScript}\"}]}]"
    "--config"
    "feedback.enabled=false"
    "--config"
    "features.codex_git_commit=false"
    "--config"
    "analytics.enabled=false"
  ];
  wrapCodexPackage =
    package: binary:
    let
      version = lib.getVersion package;
    in
    (pkgs.writeShellScriptBin binary ''
      exec ${package}/bin/${binary} ${lib.escapeShellArgs codexConfigArgs} "$@"
    '').overrideAttrs
      (old: {
        inherit version;
        name = "${binary}-${version}";
        meta = package.meta or { };
        passthru = (old.passthru or { }) // {
          unwrapped = package;
        };
      });
in
{
  home.sessionVariables = {
    DISABLE_TELEMETRY = "1";
    OTEL_METRICS_EXPORTER = "";
    CLAUDE_CODE_ENABLE_TELEMETRY = "0";
    CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
  };
  home.packages = with pkgs; [
    ast-grep
    (wrapCodexPackage codex-acp "codex-acp")
    fd
    jq
    parallel
    ripgrep
    sd
    yq-go
  ];
  programs.codex = {
    enable = true;
    package = wrapCodexPackage pkgs.codex "codex";
    enableMcpIntegration = true;
    skills = ./skills;
    context = ./rules/git-repos.md;
    settings = { };
  };
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    rulesDir = ./rules;
    skills = ./skills;
    # some settings are undocumented, refer to the schema
    # https://www.schemastore.org/claude-code-settings.json
    settings = {
      inherit hooks;
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
