{ libvterm-neovim, fetchurl }:
let libvterm-neovim-version = "0.3.3";
in libvterm-neovim.overrideAttrs (o: {
  version = libvterm-neovim-version;
  src = fetchurl {
    url =
      "https://github.com/neovim/libvterm/archive/refs/tags/v${libvterm-neovim-version}.tar.gz";
    sha256 = "sha256-C6vjq0LDVJJdre3pDTUvBUqpxK5oQuqAOiDJdB4XLlY=";
  };
})
