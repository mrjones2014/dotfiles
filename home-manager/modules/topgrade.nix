{
  programs.topgrade = {
    enable = true;
    settings = {
      assume_yes = true;
      pre_commands = {
        "Update Neovim Plugins" =
          "update-nvim-plugins"; # alias defined in shell config
      };
      commands = {
        "Unquarantine Librewolf" =
          "xattr -d com.apple.quarantine /Applications/LibreWolf.app || echo 'Already done'";
      };
    };
  };
}
