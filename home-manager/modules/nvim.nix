{ config, pkgs, ... }:
let
  inherit (pkgs) stdenv;
  inherit (stdenv) isLinux;
in {
  home.sessionVariables = {
    MANPAGER = "nvim -c 'Man!' -o -";
    LIBSQLITE = if isLinux then
      "${pkgs.sqlite.out}/lib/libsqlite3.so"
    else
      "${pkgs.sqlite.out}/lib/libsqlite3.dylib";
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
    "codespell/custom_dict.txt".text = ''
      crate
      Crate
    '';
    "cbfmt.toml".text = ''
      [languages]
      rust = ["rustfmt"]
      go = ["gofmt"]
      lua = ["stylua --config-path ${config.home.homeDirectory}/git/dotfiles/nvim/stylua.toml -s -"]
      nix = ["nixfmt"]
    '';
    "ripgrep_ignore".text = ''
      .git/
      yarn.lock
      package-lock.json
      packer_compiled.lua
      .DS_Store
      .netrwhist
      dist/
      node_modules/
      **/node_modules/
      wget-log
      wget-log.*
      /vendor
    '';
    "nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/git/dotfiles/nvim";
      recursive = true;
    };
  };

  programs.neovim = {
    package = pkgs.neovim-nightly;
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = false;
    withRuby = false;
    withPython3 = false;
    defaultEditor = true;
    coc.enable = false;

    extraPackages = with pkgs; [
      # for compiling Treesitter parsers
      gcc

      # formatters and linters
      nixfmt
      rustfmt
      shfmt
      cbfmt
      stylua
      codespell
      statix
      luajitPackages.luacheck
      nodePackages_latest.prettier

      # LSP servers
      efm-langserver
      nil
      rust-analyzer
      taplo
      gopls
      lua
      shellcheck
      marksman
      sumneko-lua-language-server
      nodePackages_latest.typescript-language-server

      # this includes css-lsp, html-lsp, json-lsp, eslint-lsp
      nodePackages_latest.vscode-langservers-extracted

      # other utils and plugin dependencies
      ripgrep
      fd
      catimg
      sqlite
      lemmy-help
      luajitPackages.jsregexp
      fzf
      cargo
      cargo-nextest
    ];
  };
}
