{ lib, ... }: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    let name = lib.getName pkg;
    in builtins.elem name [
      "spotify"
      "nvidia-persistenced"
      "nvidia-x11"
      "nvidia-settings"
      "1password"
      "1password-cli"
      "steam"
      "steam-run"
      "steam-original"
      "steam-unwrapped"
      "parsec-bin"
      "libXNVCtrl" # for some NVIDIA driver shit
      # This is required for pkgs.nodePackages_latest.vscode-langservers-extracted on NixOS
      # however VS Code should NOT be installed on this system!
      # Use VS Codium instead: https://github.com/VSCodium/vscodium
      "vscode"
    ] ||
    # CUDA has like a billion different packages for some reason
    # so just allow all CUDA packages
    pkg.meta.license.shortName == "CUDA EULA";
}

