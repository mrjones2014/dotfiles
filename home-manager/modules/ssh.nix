{
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
    };
  };
}
