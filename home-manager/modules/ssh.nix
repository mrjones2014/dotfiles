{
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    matchBlocks = {
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
