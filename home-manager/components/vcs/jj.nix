{
  config,
  lib,
  isServer,
  ...
}:
let
  palette = import ../tokyonight_palette.nix { inherit lib; };
in
{
  programs.jujutsu = {
    enable = true;
    settings = {
      templates.git_push_bookmark = ''"mrj/push-" ++ change_id.short()'';
      git.private-commits = lib.mkDefault "description(glob:'wip:*') | description(glob:'private:*')";
      experimental-advance-branches = {
        enabled-branches = [ "glob:*" ];
        disabled-branches = [
          "master"
          "main"
        ];
      };
      revset-aliases = lib.mkDefault {
        # The `trunk().. &` bit is an optimization to scan for non-`mine()` commits
        # only among commits that are not in `trunk()`
        # This prevents me from mutating any commit that isn't authored by me
        "immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";
      };
      colors = {
        # lighten these up a bit for statusline integration
        "change_id rest" = palette.dark3;
        "commit_id rest" = palette.dark3;
      };
      aliases = {
        # https://shaddy.dev/notes/jj-tug/
        tug = [
          "bookmark"
          "move"
          "--from"
          "heads(::@- & (bookmarks() ~ trunk()))"
          "--to"
          "@-"
        ];
      };
      user = {
        name = config.programs.git.userName;
        email = config.programs.git.userEmail;
      };
      signing =
        {
          inherit (config.programs.git.signing) key;
          behavior = "force";
          backend = "ssh";
        }
        // lib.optionalAttrs (!isServer) {
          backends.ssh.program = config.programs.git.extraConfig.gpg.ssh.program;
        };
    };
  };
}
