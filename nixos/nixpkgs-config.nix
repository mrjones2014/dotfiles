{
  pkgs,
  lib,
  isServer,
  ...
}:
{
  nixpkgs = {
    overlays = [
      (final: prev: (import ../pkgs { inherit pkgs; }))
    ];
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) (
        [
          "1password-cli"
          "copilot-language-server"
        ]
        ++ lib.lists.optionals (!isServer) [
          "spotify"
          "1password"
          "steam"
          "steam-run"
          "steam-original"
          "steam-unwrapped"
          "parsec-bin"
          "7zz"
        ]
      );
  };
}
