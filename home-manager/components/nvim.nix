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
      nixfmt-rfc-style
      rustfmt
      shfmt
      stylua
      statix
      selene
      prettierd
      eslint_d
      yamlfmt

      # LSP servers
      nixd
      nil
      rust-analyzer
      cargo # sometimes required for rust-analyzer to work
      taplo
      gopls
      lua
      shellcheck
      marksman
      sumneko-lua-language-server
      nodePackages_latest.typescript-language-server
      yaml-language-server
      bash-language-server
      graphql-language-service-cli
      # this includes css-lsp, html-lsp, json-lsp, eslint-lsp
      vscode-langservers-extracted
      copilot-language-server
      nodejs
      llvmPackages.clang-tools

      # other utils and plugin dependencies
      gnumake
      ripgrep
      fd
      sqlite
      lemmy-help
      fzf
      cargo
      cargo-nextest
      clippy
      glow
      mariadb
      imagemagick
      jq
      openssl
      curl
    ];
  };
}
