{ lib, ... }:
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    let
      name = lib.getName pkg;
    in
    builtins.elem name [
      "spotify"
      "1password"
      "1password-cli"
      "steam"
      "steam-run"
      "steam-original"
      "steam-unwrapped"
      "parsec-bin"
      "copilot-language-server"
    ];
}
