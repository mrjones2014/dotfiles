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
  programs = {
    fish = {
      interactiveShellInit = ''
        export SUDO_ASKPASS="${op_sudo_password_script}/bin/opsudo"
        alias sudo="sudo -A"
      '';
      functions.gh = {
        description = "Run GitHub CLI with token from 1Password";
        body = ''
          # don't prompt for auth if the command doesn't need it
          if test (count $argv) -eq 0; or contains -- --help $argv; or contains -- -h $argv; or contains -- --version $argv; or test "$argv[1]" = help; or test "$argv[1]" = version; or contains -- __complete $argv
              ${pkgs.gh}/bin/gh $argv
              return
          end

          # default to personal token
          set -l token "op://Private/GitHub/token"
          set -l account_uuid ZE3GMX56H5CV5J5IU5PLLFG4KQ
          set -l url (git config --get remote.origin.url 2>/dev/null)
          # check if we are in a work repo, and
          # set the correct token based on that
          if string match -q -r 'github\.com:agilebits-inc' "$url"
              set token "op://Employee/1Password GitHub Token/credential"
              set account_uuid S2EWWY7HCZDGFOQ7WOPBGAC2LY
          end
          GITHUB_TOKEN=(op read --account "$account_uuid" "$token") ${pkgs.gh}/bin/gh $argv
        '';
      };
    };
  };
}
