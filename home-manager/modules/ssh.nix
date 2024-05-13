{ isLinux, ... }: {
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    matchBlocks = {
      "*" = {
        extraOptions = {
          IdentityAgent = ''
            "~/${
              if isLinux then
                ".1password"
              else
                "Library/Group Containers/2BUA8C4S2C.com.1password/t"
            }/agent.sock"'';
        };
      };
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
    };
  };
}
