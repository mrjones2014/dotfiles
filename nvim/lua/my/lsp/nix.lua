return {
  settings = {
    nixd = {
      options = {
        nixos = {
          expr = string.format(
            '(builtins.getFlake ("git+file://" + toString %s/git/dotfiles/.)).nixosConfigurations.pc.options',
            vim.env.HOME
          ),
        },
        home_manager = {
          expr = string.format(
            -- line is too long
            -- luacheck: ignore
            '(builtins.getFlake ("git+file://" + toString %s/git/dotfiles/.)).nixosConfigurations."%s".modules.home-manager',
            vim.env.HOME,
            vim.uv.os_uname().sysname == 'Darwin' and 'Darwin' or 'pc'
          ),
        },
        nix_darwin = {
          expr = string.format(
            -- line is too long
            -- luacheck: ignore
            '(builtins.getFlake ("git+file://" + toString %s/git/dotfiles/.)).darwinConfigurations."Darwin".options',
            vim.env.HOME
          ),
        },
      },
    },
  },
}
