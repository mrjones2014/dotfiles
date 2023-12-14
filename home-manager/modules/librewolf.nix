{ pkgs, ... }: {
  programs.librewolf = {
    enable = pkgs.stdenv.isLinux; # broken on macOS currently :|
    settings = { "webgl.disabled" = false; }; # enable WebGL
  };
}
