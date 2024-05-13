{ isLinux, isServer, lib, ... }:
let
  sshAuthSock = "~/${
      if isLinux then
        ".1password"
      else
        "Library/Group Containers/2BUA8C4S2C.com.1password/t"
    }/agent.sock";
in {
  home.sessionVariables = { } // lib.optionalAttrs (!isServer) {
    SSH_AUTH_SOCK = "$HOME/${lib.strings.removePrefix "~/" sshAuthSock}";
  };
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    matchBlocks = {
      "nixos-server" = {
        port = 6969;
        hostname = "192.168.146.119";
      };
      "gitlab.1password.io" = {
        port = 2227;
        hostname = "ssh.gitlab.1password.io";
      };
      "*.gitlab.1password.io" = {
        port = 2227;
        hostname = "ssh.gitlab.1password.io";
      };
    } // lib.optionalAttrs (!isServer) {
      # allow SSH_AUTH_SOCK to be forwarded on server from SSH client
      "*" = { extraOptions = { IdentityAgent = ''"${sshAuthSock}"''; }; };
    };
  };
}
