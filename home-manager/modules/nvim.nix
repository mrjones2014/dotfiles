{ config, pkgs, ... }: {
  home.sessionVariables = {
    MANPAGER = "nvim -c 'Man!' -o -";
    LIBSQLITE = "${pkgs.sqlite.out}/lib/libsqlite3.dylib";
  };

  programs.fish.shellAliases = {
    # lol, sometimes I'm stupid
    ":q" = "exit";
    ":Q" = "exit";
    # I swear I'm an idiot sometimes
    ":e" = "nvim";
    update-nvim-plugins = "nvim --headless '+Lazy! sync' +qa";
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withRuby = false;
    withPython3 = false;
    defaultEditor = true;
    coc.enable = false;

    extraPackages = [
      pkgs.nixfmt
      pkgs.ripgrep
      pkgs.catimg
      pkgs.sqlite
      pkgs.luajitPackages.jsregexp
      pkgs.fzf
    ];
  };

  xdg.configFile."nvim" = {
    source = ../../nvim;
    recursive = true;
  };
}
