{
  config,
  lib,
  pkgs,
  ...
}:
let
  sshAuthSock = "${config.home.homeDirectory}/${
    if pkgs.stdenv.hostPlatform.isLinux then
      ".1password"
    else
      "Library/Group Containers/2BUA8C4S2C.com.1password/t"
  }/agent.sock";
  work_public_key = pkgs.writeText "agilebits.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGAjOfOY+u3Ei+idMfwQ/KD/X1S+JNrsc7ffN/NY8kqX";
  personal_public_key = pkgs.writeText "personal.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDsT6GLG7sY8YKX7JM+jqS3EAti3YMzwHKWViveqkZvu";
in
{
  home.sessionVariables =
    { } // lib.optionalAttrs config.dotfiles._1password.enable { SSH_AUTH_SOCK = sshAuthSock; };
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false; # defaults are going away, this is suggested by a build warning
    settings = {
      "*" = {
        forwardAgent = true;
        addKeysToAgent = "no";
        compression = false;
      }
      // lib.optionalAttrs config.dotfiles._1password.enable {
        # allow SSH_AUTH_SOCK to be forwarded on server from SSH client
        IdentityAgent = ''"${sshAuthSock}"'';
      };
    }
    // lib.optionalAttrs config.dotfiles.work {
      "Match host github.com command \"*agilebits-inc/*\"" = {
        user = "git";
        identityFile = "${work_public_key}";
        identitiesOnly = true;
      };
      "Match host github.com !command \"*agilebits-inc/*\"" = {
        user = "git";
        identityFile = "${personal_public_key}";
        identitiesOnly = true;
      };
    };
  };
  programs.git.settings.url = lib.optionalAttrs config.dotfiles.work {
    "git@github.com:agilebits-inc/".insteadOf = "https://github.com/agilebits-inc/";
  };
}
