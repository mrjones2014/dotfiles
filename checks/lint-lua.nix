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
    pushd ${self}/nvim
    selene ${self}/nvim
    stylua ${self}/nvim
    popd
    touch $out
  ''
