# NB: This relies on `programs._1password.enable = true;` being set in OS config
# e.g. NixOS config or nix-darwin config. If we install `op` via `home.packages`,
# on Linux it will not be able to connect to the 1Password desktop app.
# The NixOS module does some workarounds to make sure this works.
{ pkgs, ... }:
let
  op_sudo_password_script = pkgs.writeShellScriptBin "opsudo" ''
    PASSWORD="$(op read "op://Private/System Password/password" --account 3UBYV6PWJZAS7HTEKHDSQ7HPUA)"
    if [[ -z "$PASSWORD" ]]; then
      echo "Failed to get password from 1Password."
      read -r -s -p "󰌾 Password: " PASSWORD
    fi

    echo "$PASSWORD"
  '';

  gh = pkgs.writeShellScriptBin "gh" ''
    # pass through commands that don't need auth
    case "''${1:-}" in
      --help|-h|--version|help|version|__complete|"")
        exec ${pkgs.gh}/bin/gh "$@"
        ;;
    esac

    # default to personal token
    token="op://Private/GitHub/token"
    account_uuid="3UBYV6PWJZAS7HTEKHDSQ7HPUA"

    url="$(git config --get remote.origin.url 2>/dev/null || true)"
    if [[ "$url" == *"github.com:agilebits-inc"* ]]; then
      token="op://Employee/1Password GitHub Token/credential"
      account_uuid="AKHM3DPGNZFUJOY7N4UAWAMLIE"
    fi

    GITHUB_TOKEN="$(op read --account "$account_uuid" "$token")" \
      exec ${pkgs.gh}/bin/gh "$@"
  '';

  # Explicit -1p variants for use in automation/skills where PATH shadowing doesn't work
  gh-1p = pkgs.writeShellScriptBin "gh-1p" ''
    exec ${gh}/bin/gh "$@"
  '';
in
{
  home.packages = [
    gh
    gh-1p
  ];

  home.sessionVariables = {
    SUDO_ASKPASS = "${op_sudo_password_script}/bin/opsudo";
    # for `programs.nh`: https://github.com/nix-community/nh#nh-specific
    NH_SUDO_ASKPASS = "${op_sudo_password_script}/bin/opsudo";
  };
  programs.fish.shellAliases.sudo = "sudo -A";
}
