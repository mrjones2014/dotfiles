{
  projectRootFile = "flake.nix";
  programs = {
    nixfmt.enable = true;
    fish_indent.enable = true;
    stylua.enable = true;
    rustfmt.enable = true;
    taplo.enable = true;
    shfmt.enable = true;
    yamlfmt.enable = true;
    statix.enable = true;
    actionlint.enable = true;
  };
}
