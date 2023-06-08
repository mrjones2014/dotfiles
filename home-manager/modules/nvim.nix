{ config, pkgs, lib, ... }: {
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

  xdg.configFile = {
    "codespell/custom_dict.txt".source = ../../conf.d/codespell_dict.txt;
    "cbfmt.toml".source = ../../conf.d/cbfmt.toml;
    "ripgrep_ignore".source = ../../conf.d/ripgrep_ignore;
    "nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/git/dotfiles/nvim";
      recursive = true;
    };
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

    extraPackages = with pkgs; [
      # formatters and linters
      nixfmt
      rustfmt
      shfmt
      cbfmt
      stylua
      codespell
      luajitPackages.luacheck
      nodePackages_latest.prettier_d_slim
      nodePackages_latest.eslint_d
      nodePackages_latest.markdownlint-cli

      # LSP servers
      rnix-lsp
      rust-analyzer
      taplo
      gopls
      lua
      shellcheck
      marksman
      sumneko-lua-language-server
      nodePackages_latest.typescript-language-server
      # this includes css-lsp, html-lsp, json-lsp
      nodePackages_latest.vscode-langservers-extracted

      # other utils and plugin dependencies
      ripgrep
      fd
      catimg
      sqlite
      lemmy-help
      luajitPackages.jsregexp
      fzf
    ];
  };
}
