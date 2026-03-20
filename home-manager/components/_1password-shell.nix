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

  gh = pkgs.writeShellScriptBin "gh" ''
    # pass through commands that don't need auth
    case "''${1:-}" in
      --help|-h|--version|help|version|__complete|"")
        exec ${pkgs.gh}/bin/gh "$@"
        ;;
    esac

    # default to personal token
    token="op://Private/GitHub/token"
    account_uuid="ZE3GMX56H5CV5J5IU5PLLFG4KQ"

    url="$(git config --get remote.origin.url 2>/dev/null || true)"
    if [[ "$url" == *"github.com:agilebits-inc"* ]]; then
      token="op://Employee/1Password GitHub Token/credential"
      account_uuid="S2EWWY7HCZDGFOQ7WOPBGAC2LY"
    fi

    GITHUB_TOKEN="$(op read --account "$account_uuid" "$token")" \
      exec ${pkgs.gh}/bin/gh "$@"
  '';

  glab = pkgs.writeShellScriptBin "glab" ''
    # glab requires config file to have 600 permissions, but nix store files are 444
    # copy config to a temp dir with correct permissions
    GLAB_TMP_DIR="$(mktemp -d)"
    trap "rm -rf '$GLAB_TMP_DIR'" EXIT

    mkdir -p "$GLAB_TMP_DIR"
    cp "$HOME/.config/glab-cli/config.yml" "$GLAB_TMP_DIR/config.yml" 2>/dev/null || true
    chmod 600 "$GLAB_TMP_DIR/config.yml" 2>/dev/null || true

    export GLAB_CONFIG_DIR="$GLAB_TMP_DIR"

    # pass through commands that don't need auth
    case "''${1:-}" in
      --help|-h|--version|help|version|"")
        exec ${pkgs.glab}/bin/glab "$@"
        ;;
    esac
    GITLAB_TOKEN="$(op read "op://Employee/GitLab Personal Access Token/token" --account S2EWWY7HCZDGFOQ7WOPBGAC2LY)" \
      ${pkgs.glab}/bin/glab "$@"
  '';
in
{
  home.packages = [
    gh
    glab
  ];

  # yaml is a superset of json so this is fine
  xdg.configFile."glab-cli/config.yml".text = builtins.toJSON {
    git_protocol = "ssh";
    glamour_style = "dark";
    check_update = false;
    host = "gitlab.1password.io";
    no_prompt = false;
    telemetry = false;
    hosts."gitlab.1password.io".api_protocol = "https";
  };

  programs.fish = {
    interactiveShellInit = /* bash */ ''
      export SUDO_ASKPASS="${op_sudo_password_script}/bin/opsudo"
      alias sudo="sudo -A"
    '';
    functions = {
      # this ensures our wrappers are used even if the package is installed
      # via a project's `devShell` or similar
      gh = {
        description = "Run GitHub CLI with token from 1Password";
        body = "${gh}/bin/gh $argv";
      };
      glab = {
        description = "Run GitLab CLI with token from 1Password";
        body = "${glab}/bin/glab $argv";
      };
    };
  };
}
