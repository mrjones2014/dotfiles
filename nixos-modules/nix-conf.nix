{ pkgs, lib, isLinux, ... }: {
  nix = {
    package = lib.mkDefault pkgs.lix;
    settings = {
      keep-outputs = true;
      keep-derivations = true;
      auto-optimise-store =
        if isLinux then
          true
        else
          false; # https://github.com/NixOS/nix/issues/7273

      experimental-features = "nix-command flakes";
    };
  };
}
