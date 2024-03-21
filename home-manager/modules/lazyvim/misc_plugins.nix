{ inputs, ... }:
with inputs.lazyvim.lib; {
  programs.lazyvim.plugins = {
    "nvim-lua/plenary.nvim" = { };
    # let lazy.nvim manage itself
    "folke/lazy.nvim" = {
      lazy = false;
      keys = [{
        lhs = "<leader>L";
        rhs = lua "function() vim.cmd.Lazy() end";
      }];
    };
    "tpope/vim-eunuch" = {
      cmd = [ "Delete" "Move" "Chmod" "SudoWrite" "Rename" ];
    };
    "tpope/vim-sleuth" = { event = "BufReadPre"; };
    "mrjones2014/iconpicker.nvim" = { };
    "mrjones2014/lua-gf.nvim" = {
      dev = true;
      ft = "lua";
    };
    "echasnovski/mini.pairs" = {
      opts = {
        mappings = {
          # source: https://old.reddit.com/r/neovim/comments/163rzex/how_to_avoid_autocompleting_right_parentheses/jy4zwp8/
          # disable if a matching character is in an adjacent position (eg. fixes
          # markdown triple ticks) neigh_pattern: a pattern for *two* neighboring
          # characters (before and after). Use dot `.` to allow any character.
          # Here, we disable the functionality instead of inserting a matching quote
          # if there is an adjacent non-space character
          "`" = {
            action = "closeopen";
            pair = "``";
            neigh_pattern = "[^%S][^%S]";
            register = { cr = false; };
          };
        };
      };
    };
    "echasnovski/mini.splitjoin" = {
      keys = [{
        lhs = "gS";
        rhs = lua ''function() require("mini.splitjoin").toggle() end'';
        desc =
          "Split/join arrays, argument lists, etc. from one vs. multiline and vice versa";
      }];
    };
    "echasnovski/mini.trailspace" = {
      event = "BufRead";
      opts = { };
    };
    "max397574/better-escape.nvim" = {
      event = "InsertEnter";
      opts = { };
    };
    "saecki/crates.nvim" = {
      event = "BufRead Cargo.toml";
      opts = { };
    };
  };
}
