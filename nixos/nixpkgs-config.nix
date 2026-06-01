{
  pkgs,
  lib,
  isServer,
  ...
}:
let
  # TODO remove; see: https://github.com/NixOS/nixpkgs/pull/522452#issuecomment-4519733688
  # https://nixpk.gs/pr-tracker.html?pr=525089
  onePasswordHashes = {
    "aarch64-darwin" = "sha256-WrWbGzBK65tVNl9Dc3OnJURiPpfbNLOYUJcVT0ETaAs=";
    "x86_64-linux" = "sha256-JwiMi2iozP6jWSIUtgXla86aSAhuUob7snqtUbeXPpI=";
  };
in
{
  nixpkgs = {
    overlays = [
      (_: _: (import ../pkgs { inherit pkgs; }))
      # TODO remove see comment above
      (_: prev: {
        _1password-gui = prev._1password-gui.overrideAttrs (old: {
          src = prev.fetchurl {
            inherit (old.src) url;
            hash = onePasswordHashes.${prev.stdenv.hostPlatform.system};
          };
        });
      })
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
