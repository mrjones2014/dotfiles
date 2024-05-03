{ isLinux, ... }: {
  programs.librewolf = {
    enable = isLinux; # broken on macOS currently :|
    settings = { "webgl.disabled" = false; }; # enable WebGL
  };
}
