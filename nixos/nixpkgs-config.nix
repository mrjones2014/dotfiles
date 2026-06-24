{
  pkgs,
  lib,
  isServer,
  ...
}:
{
  nixpkgs = {
    overlays = [
      (_: _: (import ../pkgs { inherit pkgs; }))
    ];
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) (
        [
          "1password-cli"
          "claude-code"
        ]
        ++ lib.lists.optionals isServer [
        ]
        ++ lib.lists.optionals (!isServer) [
          "1password"
          "7zz"
          "discord"
          "parsec-bin"
          "spotify"
          "steam"
          "steam-original"
          "steam-run"
          "steam-unwrapped"
        ]
      );
  };
}
