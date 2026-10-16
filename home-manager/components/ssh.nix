{
  config,
  lib,
  pkgs,
  isLinux,
  isServer,
  isWorkMac,
  ...
}:
let
  sshAuthSock = "${config.home.homeDirectory}/${
    if isLinux then ".1password" else "Library/Group Containers/2BUA8C4S2C.com.1password/t"
  }/agent.sock";
  work_public_key = pkgs.writeText "agilebits.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGAjOfOY+u3Ei+idMfwQ/KD/X1S+JNrsc7ffN/NY8kqX";
  personal_public_key = pkgs.writeText "personal.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDsT6GLG7sY8YKX7JM+jqS3EAti3YMzwHKWViveqkZvu";
in
{
  home.sessionVariables = { } // lib.optionalAttrs (!isServer) { SSH_AUTH_SOCK = sshAuthSock; };
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false; # defaults are going away, this is suggested by a build warning
    settings = {
      "*" = {
        forwardAgent = true;
        addKeysToAgent = "no";
        compression = false;
      }
      // lib.optionalAttrs (!isServer) {
        # allow SSH_AUTH_SOCK to be forwarded on server from SSH client
        IdentityAgent = ''"${sshAuthSock}"'';
      };
    }
    // lib.optionalAttrs isWorkMac {
      # Exactly one key per connection: ssh offers agent keys in the agent's
      # order, so listing both lets the personal key win in work repos.
      # Work repos tag the connection via `core.sshCommand` below.
      "Match host github.com tagged work" = {
        user = "git";
        identityFile = "${work_public_key}";
        identitiesOnly = true;
      };
      "Match host github.com !tagged work" = {
        user = "git";
        identityFile = "${personal_public_key}";
        identitiesOnly = true;
      };
    };
  };
  programs.git.includes = lib.optionals isWorkMac (
    map
      (pattern: {
        condition = "hasconfig:remote.*.url:${pattern}";
        contents.core.sshCommand = "ssh -P work";
      })
      [
        "git@github.com:agilebits-inc/**"
        "ssh://git@github.com/agilebits-inc/**"
        "https://github.com/agilebits-inc/**"
      ]
  );
}
