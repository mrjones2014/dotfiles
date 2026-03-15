{ pkgs, ... }:
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
  programs.claude-code = {
    enable = true;
    memory.text = ''
      ## Installed CLI tools

      - **ast-grep** is installed — use for structural code searches and transformations on supported languages
      - **fd** is installed — prefer over `find` for file finding by name/pattern
      - **GNU parallel** is installed — use for concurrent shell tasks when beneficial
      - **jq** is installed — use for JSON processing in shell pipelines
      - **ripgrep** (`rg`) is installed — prefer over `grep` for shell searches
      - **sd** is installed — prefer over `sed` for find-and-replace in files
      - **yq** is installed — use for YAML processing in shell pipelines
    '';
  };
}
