{
  config,
  isLinux,
  isServer,
  lib,
  ...
}:
let
  sshAuthSock = "${config.home.homeDirectory}/${
    if isLinux then ".1password" else "Library/Group Containers/2BUA8C4S2C.com.1password/t"
  }/agent.sock";
in
{
  home.sessionVariables = { } // lib.optionalAttrs (!isServer) { SSH_AUTH_SOCK = sshAuthSock; };
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    matchBlocks =
      { }
      // lib.optionalAttrs (!isServer) {
        # allow SSH_AUTH_SOCK to be forwarded on server from SSH client
        "*".extraOptions.IdentityAgent = ''"${sshAuthSock}"'';
      };
  };
}
