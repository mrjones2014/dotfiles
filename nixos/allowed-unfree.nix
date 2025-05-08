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
      # This is required for pkgs.nodePackages_latest.vscode-langservers-extracted on NixOS
      # however VS Code should NOT be installed on this system!
      # Use VS Codium instead: https://github.com/VSCodium/vscodium
      "vscode"
    ];
}
