{ inputs, lib, config, ... }:
with lib;
let inherit (config) theme;
in {
  imports = [

    inputs.catppuccin.homeManagerModules.catppuccin
    inputs.tokyonight.homeManagerModules.default
  ];
  options = {
    theme = mkOption {
      type = types.enum [ "catppuccin" "tokyonight" ];
      description = "Which theme to use.";
    };
  };
  config = mkMerge [
    (mkIf (theme == "catppuccin") {
      catppuccin.flavour = "mocha";
      programs = {
        git.delta.catppuccin.enable = true;
        bat.catppuccin.enable = true;
        rofi.catppuccin.enable = true;
        fzf.catppuccin.enable = true;
        fish.catppuccin.enable = true;
        btop.catppuccin.enable = true;
        starship.catppuccin.enable = true;
      };
    })

    (mkIf (theme == "tokyonight") {
      programs = {
        git.delta.tokyonight.enable = true;
        bat.tokyonight.enable = true;
        fish.tokyonight.enable = true;
        fzf.tokyonight.enable = true;
        rofi.tokyonight = {
          enable = true;
          variant = "big1";
        };
      };
    })
  ];
}

