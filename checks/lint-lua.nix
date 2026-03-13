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
    stylua ${self}/nvim --config-path ${self}/nvim/stylua.toml
    touch $out
  ''
