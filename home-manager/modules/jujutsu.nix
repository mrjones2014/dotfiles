{ config, lib, ... }: {
  programs.jujutsu = {
    enable = true;
    settings = {
      git.private-commits = lib.mkDefault
        "description(glob:'wip:*') | description(glob:'private:*')";
      revset-aliases = lib.mkDefault {
        # The `trunk().. &` bit is an optimization to scan for non-`mine()` commits
        # only among commits that are not in `trunk()`
        # This prevents me from mutating any commit that isn't authored by me
        "immutable_heads()" =
          "builtin_immutable_heads() | (trunk().. & ~mine())";
      };
      user = {
        inherit (config.programs.git.extraConfig.user) name;
        inherit (config.programs.git.extraConfig.user) email;
      };
      signing = {
        key = config.programs.git.extraConfig.user.signingKey;
        sign-all = true;
        backend = "ssh";
        backends.ssh.program = config.programs.git.extraConfig.gpg.ssh.program;
      };
    };
  };
}
