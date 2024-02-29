{ lib, config, ... }:
with lib;
let cfg = config.programs.op-shell-plugins;
in {
  options = {
    programs.op-shell-plugins = {
      enable = mkEnableOption "1Password Shell Plugins";
      plugins = mkOption {
        type = types.listOf types.package;
        default = [ ];
        example = literalExpression ''
          with pkgs; [
            gh
            awscli2
            cachix
          ]
        '';
        description =
          "CLI Packages to enable 1Password Shell Plugins for; ensure that a Shell Plugin exists by checking the docs: https://developer.1password.com/docs/cli/shell-plugins/";
      };
    };
  };

  config = let
    aliases = ''
      export OP_PLUGIN_ALIASES_SOURCED=1
      ${concatMapStrings
      (plugin: ''alias ${plugin}="op plugin run -- ${plugin}"'')
      (map (package: builtins.baseNameOf (lib.getExe package)) cfg.plugins)}
    '';
  in mkIf cfg.enable (mkMerge [{
    home.packages = [ pkgs._1password ] ++ cfg.plugins;
    programs = {
      fish.interactiveShellInit = ''
        ${aliases}
      '';
      bash.initExtra = ''
        ${aliases}
      '';
      zsh.initExtra = ''
        ${aliases}
      '';
    };
  }]);
}
