{ config, lib, ... }:
{
  options.dotfiles = {
    headless = lib.mkEnableOption "headless/server profile (no GUI, no local 1Password)";
    work = lib.mkEnableOption "work machine profile";
    _1password.enable = lib.mkOption {
      type = lib.types.bool;
      default = !config.dotfiles.headless;
      description = "1Password SSH agent + commit signing integration";
    };
  };
}
