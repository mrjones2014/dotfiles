{ config, ... }: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withRuby = false;
    withPython3 = false;
    defaultEditor = true;
  };

  # link my Neovim files in-place so I don't have to reapply the flake
  # just to change Neovim configs. I still need to reapply the flake if
  # I add a new file or delete a file.
  home.activation.linkNvimConfig =
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      ln -f -s ${toString ../../nvim} ${config.xdg.configHome}/nvim
    '';
}
