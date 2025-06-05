{ inputs, pkgs, ... }:
let
  op_sudo_password_script = pkgs.writeShellScriptBin "opsudo.bash" ''
    # TODO figure out a way to do this without silently depending on `op` being on $PATH
    # using `$\{pkgs._1password}/bin/op` results in unable to connect to desktop app
    PASSWORD="$(op read "op://Private/System Password/password")"
    if [[ -z "$PASSWORD" ]]; then
      echo "Failed to get password from 1Password."
      read -s -p "Password: " PASSWORD
    fi

    echo $PASSWORD
  '';
in
{
  home.packages = with pkgs; [ _1password-cli ];
  imports = [ inputs._1password-shell-plugins.hmModules.default ];
  programs = {
    fish = {
      interactiveShellInit = ''
        export SUDO_ASKPASS="${op_sudo_password_script}"
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
