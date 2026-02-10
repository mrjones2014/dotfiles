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
    matchBlocks = {
      "*" = {
        forwardAgent = true;
        addKeysToAgent = "no";
        compression = false;
      }
      // lib.optionalAttrs (!isServer) {
        # allow SSH_AUTH_SOCK to be forwarded on server from SSH client
        extraOptions.IdentityAgent = ''"${sshAuthSock}"'';
      };
    }
    // lib.optionalAttrs isWorkMac {
      "gitlab.1password.io".port = 2227;
      # host alias to disambiguate work from personal projects;
      "github-enterprise" = {
        hostname = "github.com";
        user = "git";
        identityFile = "${work_public_key}";
        identitiesOnly = true;
      };
      "github.com" = {
        user = "git";
        identityFile = "${personal_public_key}";
        identitiesOnly = true;
      };
    };
  };
  programs.git.settings.url = lib.optionalAttrs isWorkMac {
    "git@github-enterprise:agilebits-inc/".insteadOf = "git@github.com:agilebits-inc/";
    "git@github-enterprise:agilebits-tst-EMU/".insteadOf = "git@github.com:agilebits-tst-EMU/";
  };
}
