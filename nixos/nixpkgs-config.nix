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
        ]
        ++ lib.lists.optionals isServer [
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
          "discord"
          "claude-code-bin"
        ]
      );
  };
}
