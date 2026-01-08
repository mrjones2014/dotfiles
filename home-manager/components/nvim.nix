{
  config,
  pkgs,
  isLinux,
  ...
}:
{
  xdg.configFile = {
    ripgrep_ignore.text = ''
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
    nvim = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/dotfiles/nvim";
      recursive = true;
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = false;
    withRuby = false;
    withPython3 = false;
    defaultEditor = true;
    coc.enable = false;

    extraWrapperArgs = [
      "--set"
      "NVIM_RUST_ANALYZER"
      "${pkgs.rust-analyzer}/bin/rust-analyzer"
      "--set"
      "LIBSQLITE"
    ]
    ++ (
      if isLinux then
        [ "${pkgs.sqlite.out}/lib/libsqlite3.so" ]
      else
        [ "${pkgs.sqlite.out}/lib/libsqlite3.dylib" ]
    );

    extraLuaPackages = ps: [ ps.jsregexp ];
    extraPackages = with pkgs; [
      # for compiling Treesitter parsers
      gcc
      tree-sitter

      # debuggers
      lldb # comes with lldb-vscode

      # formatters and linters
      eslint_d
      nixfmt-rfc-style
      prettierd
      rustfmt
      selene
      shfmt
      statix
      stylua
      yamlfmt

      # LSP servers
      bash-language-server
      cargo # sometimes required for rust-analyzer to work
      copilot-language-server
      gopls
      graphql-language-service-cli
      just-lsp
      llvmPackages.clang-tools
      lua
      lua-language-server
      marksman
      nil
      nixd
      nodePackages_latest.typescript-language-server
      nodejs
      rust-analyzer
      shellcheck
      taplo
      vscode-langservers-extracted # this includes css-lsp, html-lsp, json-lsp, eslint-lsp
      yaml-language-server

      # other utils and plugin dependencies
      cargo
      cargo-nextest
      clippy
      curl
      fd
      fzf
      glow
      gnumake
      imagemagick
      jq
      lemmy-help
      mariadb
      openssl
      ripgrep
      sqlite
      yq-go
    ];
  };
}
