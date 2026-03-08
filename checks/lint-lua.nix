{
  pkgs,
  self,
}:
pkgs.runCommand "lint-lua"
  {
    nativeBuildInputs = [
      pkgs.selene
      pkgs.stylua
    ];
  }
  ''
    selene ${self}/nvim --config ${self}/nvim/selene.toml
    stylua check ${self}/nvim
    touch $out
  ''
