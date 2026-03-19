return {
  cmd = { 'nixd' },
  filetypes = { 'nix' },
  root_markers = { 'flake.nix', 'default.nix', '.git' },
  ---@type lsp.nixd
  settings = {
    nixd = {
      options = {
        nixos = {
          expr = string.format(
            '(builtins.getFlake ("git+file://" + toString %s/git/dotfiles/.)).nixosConfigurations."edgerunner".options',
            vim.env.HOME
          ),
        },
        home_manager = {
          expr = string.format(
            '(builtins.getFlake ("git+file://" + toString %s/git/dotfiles/.)).nixosConfigurations."edgerunner".modules.home-manager',
            vim.env.HOME
          ),
        },
        nix_darwin = {
          expr = string.format(
            '(builtins.getFlake ("git+file://" + toString %s/git/dotfiles/.)).darwinConfigurations."aldecaldo".options',
            vim.env.HOME
          ),
        },
      },
    },
  },
}
