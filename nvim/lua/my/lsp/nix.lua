return {
  settings = {
    nixd = {
      options = {
        nixos = {
          expr = string.format(
            '(builtins.getFlake ("git+file://" + toString %s/git/dotfiles/.)).nixosConfigurations.tower.options',
            vim.env.HOME
          ),
        },
        home_manager = {
          expr = string.format(
            -- line is too long
            -- luacheck: ignore
            '(builtins.getFlake ("git+file://" + toString %s/git/dotfiles/.)).nixosConfigurations."tower".modules.home-manager',
            vim.env.HOME
          ),
        },
        nix_darwin = {
          expr = string.format(
            -- line is too long
            -- luacheck: ignore
            '(builtins.getFlake ("git+file://" + toString %s/git/dotfiles/.)).darwinConfigurations."darwin".options',
            vim.env.HOME
          ),
        },
      },
    },
  },
}
