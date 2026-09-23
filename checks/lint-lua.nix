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
    pushd ${self}/nvim-astro
    selene ${self}/nvim-astro
    stylua ${self}/nvim-astro
    popd
    touch $out
  ''
