{
  pkgs,
  user,
  home,
  sudo,
}:
let
  login = pkgs.writeShellApplication {
    name = "paperless-proton-login-internal";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
      gawk
      gnupg
      pass
      proton-drive-cli
      util-linux
    ];
    text = ''
      umask 077
      export HOME=${pkgs.lib.escapeShellArg home}
      export GNUPGHOME="$HOME/gnupg"
      export PASSWORD_STORE_DIR="$HOME/password-store"
      export XDG_CACHE_HOME="$HOME/cache"
      export XDG_DATA_HOME="$HOME/data"
      export XDG_STATE_HOME="$HOME/state"
      export PROTON_DRIVE_CREDENTIALS_STORE=pass
      unset PROTON_DRIVE_CACHE_DIR
      export GPG_TTY
      GPG_TTY="$(tty)"

      mkdir -p "$GNUPGHOME" "$PASSWORD_STORE_DIR"
      chmod 700 "$GNUPGHOME" "$PASSWORD_STORE_DIR"
      exec 9>"$HOME/.lock"
      if ! flock -n 9; then
        echo "A Paperless Proton backup or login is already running." >&2
        exit 1
      fi

      if [[ ! -s "$PASSWORD_STORE_DIR/.gpg-id" ]]; then
        if [[ -e "$PASSWORD_STORE_DIR/.gpg-id" ]] || [[ -n "$(find "$PASSWORD_STORE_DIR" -name '*.gpg' -print -quit)" ]]; then
          echo "The pass store is incomplete; refusing to reinitialize it." >&2
          exit 1
        fi
        key_listing="$(gpg --batch --with-colons --list-secret-keys)"
        mapfile -t fingerprints < <(printf '%s\n' "$key_listing" | awk -F: '
          $1 == "sec" { primary = 1; next }
          $1 == "fpr" && primary { print $10; primary = 0 }
        ')
        if [[ ''${#fingerprints[@]} -eq 0 ]]; then
          echo "Creating a dedicated GPG key without a passphrase for unattended backups."
          gpg --batch --pinentry-mode loopback --passphrase "" \
            --quick-generate-key "Paperless Proton Drive backup" default default never
          key_listing="$(gpg --batch --with-colons --list-secret-keys)"
          mapfile -t fingerprints < <(printf '%s\n' "$key_listing" | awk -F: '
            $1 == "sec" { primary = 1; next }
            $1 == "fpr" && primary { print $10; primary = 0 }
          ')
        fi
        if [[ ''${#fingerprints[@]} -ne 1 ]]; then
          echo "Expected exactly one GPG key; refusing to initialize the pass store." >&2
          exit 1
        fi
        pass init "''${fingerprints[0]}"
      fi

      proton-drive auth login
    '';
  };
in
pkgs.writeShellApplication {
  name = "paperless-proton-login";
  text = ''
    if [[ $# -ne 0 ]]; then
      echo "Usage: paperless-proton-login" >&2
      exit 1
    fi
    if [[ ! -t 0 ]]; then
      echo "An interactive terminal is required." >&2
      exit 1
    fi
    exec ${sudo} -u ${pkgs.lib.escapeShellArg user} -- ${login}/bin/paperless-proton-login-internal
  '';
}
