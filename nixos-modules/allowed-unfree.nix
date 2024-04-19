{ lib, ... }: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
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
      "cudatoolkit"
      "cuda_cudart"
      "cuda-merged"
      "cuda_cuobjdump"
    ];
}

