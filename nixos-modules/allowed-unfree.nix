{ lib, ... }: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    let name = lib.getName pkg;
    in builtins.elem name [
      "obsidian"
      "discord"
      "spotify"
      "nvidia-persistenced"
      "nvidia-x11"
      "nvidia-settings"
      "1password"
      "1password-cli"
      "steam"
      "steam-run"
      "steam-original"
      "parsec-bin"
      # This is required for pkgs.nodePackages_latest.vscode-langservers-extracted on NixOS
      # however VS Code should NOT be installed on this system!
      # Use VS Codium instead: https://github.com/VSCodium/vscodium
      "vscode"

      # CUDA support (e.g. for Ollama)
      "libcublas"
    ] ||
    # CUDA has like a billion different packages for some reason
    # so just allow all CUDA packages
    (builtins.substring 0 4 name) == "cuda";
}

