# NB: This relies on `programs._1password.enable = true;` being set in OS config
# e.g. NixOS config or nix-darwin config. If we install `op` via `home.packages`,
# on Linux it will not be able to connect to the 1Password desktop app.
# The NixOS module does some workarounds to make sure this works.
{ pkgs, ... }:
let
  op_sudo_password_script = pkgs.writeShellScriptBin "opsudo" ''
    PASSWORD="$(op read "op://Private/System Password/password" --account ZE3GMX56H5CV5J5IU5PLLFG4KQ)"
    if [[ -z "$PASSWORD" ]]; then
      echo "Failed to get password from 1Password."
      read -r -s -p "󰌾 Password: " PASSWORD
    fi

    echo "$PASSWORD"
  '';
in
{
  imports = [ ../modules/_1password-shell-plugins.nix ];
  programs = {
    fish = {
      interactiveShellInit = ''
        export SUDO_ASKPASS="${op_sudo_password_script}/bin/opsudo"
        alias sudo="sudo -A"
      '';
    };
    _1password-shell-plugins = {
      enable = true;
      plugins = with pkgs; [
        gh
        glab
      ];
    };
  };
}
