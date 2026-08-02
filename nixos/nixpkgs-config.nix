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
      (
        _: prev:
        lib.optionalAttrs prev.stdenv.isDarwin {
          nixos-render-docs = prev.writeShellScriptBin "nixos-render-docs" ''
            args=()
            while [ "$#" -gt 0 ]; do
              case "$1" in
                --toc-depth)
                  args+=(--sidebar-depth "$2")
                  shift 2
                  ;;
                --toc-depth=*)
                  args+=(--sidebar-depth "''${1#--toc-depth=}")
                  shift
                  ;;
                *)
                  args+=("$1")
                  shift
                  ;;
              esac
            done

            exec ${lib.getExe prev.nixos-render-docs} "''${args[@]}"
          '';
        }
      )
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
