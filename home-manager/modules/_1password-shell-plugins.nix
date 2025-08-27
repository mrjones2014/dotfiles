{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.programs._1password-shell-plugins;

  getExeName =
    package:
    # SAFETY: This is okay because the `packages` list is also referred
    # to below as `home.packages = packages;` or `environment.systemPackages = packages;`
    # depending on if it's using `home-manager` or not; this means that Nix can still
    # compute the dependency tree, even though we're discarding string context here,
    # since the packages are still referred to below without discarding string context.
    lib.strings.unsafeDiscardStringContext (baseNameOf (lib.getExe package));
in
{
  options = {
    programs._1password-shell-plugins = {
      enable = lib.mkEnableOption "1Password Shell Plugins";
      plugins = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        example = lib.literalExpression ''
          with pkgs; [
            gh
            awscli2
            cachix
          ]
        '';
        description = "CLI Packages to enable 1Password Shell Plugins for";
      };
    };
  };

  config =
    let
      pkg-exe-names = map getExeName cfg.plugins;

      fish-functions = lib.listToAttrs (
        map (exe: {
          name = exe;
          value = {
            wraps = exe;
            description = "1Password Shell Plugin for ${exe}";
            body = "op plugin run -- ${exe} $argv";
          };
        }) pkg-exe-names
      );

      packages = [ pkgs._1password-cli ] ++ cfg.plugins;
    in
    lib.mkIf cfg.enable (
      lib.mkMerge [
        {
          programs.fish.functions = fish-functions;
          home = {
            inherit packages;
            sessionVariables = {
              OP_PLUGINS_SOURCED = "1";
            };
          };
        }
      ]
    );
}
