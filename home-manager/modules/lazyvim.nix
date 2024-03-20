{ inputs, ... }: {
  imports = [ inputs.lazyvim.nixosModules.default ];
  programs.lazyvim = {
    enable = true;
    mapleader = " ";
    opts = {
      showtabline = 0;
      signcolumn = "yes:3";
    };
    plugins = {
      "mrjones2014/smart-splits.nvim" = {
        dev = true;
        event = "WinNew";
        opts = { ignored_buftypes = [ "nofile" ]; };
      };
    };
  };
}

