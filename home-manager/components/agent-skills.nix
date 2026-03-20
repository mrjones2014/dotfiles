{ config, ... }:
let
  skillsSource = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/dotfiles/agent/skills";
in
{
  home.file = {
    ".claude/skills".source = skillsSource;
    ".cursor/skills".source = skillsSource;
  };
}
