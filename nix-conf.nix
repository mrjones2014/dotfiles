{ pkgs, lib, isLinux, ... }: {
  nix = {
    package = lib.mkDefault pkgs.lix;
    settings = {
      keep-outputs = true;
      keep-derivations = true;
      auto-optimise-store = if isLinux then
        true
      else
        false; # https://github.com/NixOS/nix/issues/7273

      experimental-features = "nix-command flakes";
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://mrjones2014-dotfiles.cachix.org"
        "https://wezterm.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "mrjones2014-dotfiles.cachix.org-1:c66wfzthG6KZEWnltlzW/EjhlH9FwUVi5jM4rVD1Rw4="
        "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
      ];
    };
  };
}
