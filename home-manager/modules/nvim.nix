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

    plugins = [ pkgs.vimPlugins.nvim-treesitter.withAllGrammars ];

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
      # this includes css-lsp, html-lsp, json-lsp
      rnix-lsp
      rust-analyzer
      gopls
      lua
      shellcheck
      marksman
      sumneko-lua-language-server
      nodePackages_latest.vscode-langservers-extracted
      nodePackages_latest.typescript-language-server

      # other utils and plugin dependencies
      ripgrep
      catimg
      sqlite
      lemmy-help
      luajitPackages.jsregexp
      fzf
    ];
  };

  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/git/dotfiles/nvim";
    recursive = true;
  };
}
