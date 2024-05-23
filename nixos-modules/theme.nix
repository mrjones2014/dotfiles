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
      home.sessionVariables.COLORSCHEME = "catppuccin";
      # enable globally for all supported programs
      catppuccin = {
        enable = true;
        flavor = "mocha";
      };
      # My Neovim Lua is not generated by Nix
      programs.neovim.catppuccin.enable = false;
    })

    (mkIf (theme == "tokyonight") {
      home.sessionVariables.COLORSCHEME = "tokyonight";
      # enable globally for all supported programs
      tokyonight = {
        enable = true;
        style = "night";
      };
      programs = {
        # My Neovim Lua is not generated by Nix
        neovim.tokyonight.enable = false;
        rofi.tokyonight.variant = "big1";
      };
    })
  ];
}

