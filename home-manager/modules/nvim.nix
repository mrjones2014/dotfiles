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
    source = ../../nvim;
    recursive = true;
  };
}

# { "css-lsp", "svelte-language-server", "rnix-lsp", "typescript-language-server", "prettier", "prettierd", "eslint_d", "rust-analyzer", "rustfmt", "shellcheck", "shfmt", "json-lsp", "marksman", "cbfmt", "markdownlint", "gopls", "lua-language-server", "stylua", "luacheck", "html-lsp", "codespell", "lemmy-help", "tree-sitter-cli" }
