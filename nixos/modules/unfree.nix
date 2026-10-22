{ config, lib, ... }:
{
  options.dotfiles.unfree.packageNames = lib.mkOption {
    default = [ ];
    description = "List of unfree package names to allowlist";
    type = lib.types.listOf lib.types.str;
  };

  config.nixpkgs.config.allowUnfreePredicate =
    pkg: builtins.elem (lib.getName pkg) config.dotfiles.unfree.packageNames;
}
