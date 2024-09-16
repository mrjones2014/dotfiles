{ pkgs, ... }: {
  home.packages = with pkgs; [
    nixfmt
    statix
    shfmt
    prettierd
    rustfmt
    rust-analyzer
    gopls
    shellcheck
    maple-mono
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];

  xdg.configFile."zed/settings.json".text = builtins.toJSON {
    telemetry = {
      diagnostics = false;
      metrics = false;
    };
    features = {
      # disable github copilot
      inline_completion_provider = "none";
    };
    vim_mode = true;
    ui_font_size = 16;
    buffer_font_size = 16;
    buffer_font_family = "Maple Mono";
    buffer_font_fallbacks = [ "Symbols Nerd Font Mono" ];
    buffer_font_features = {
      cv03 = true;
      ss01 = true;
      ss02 = true;
      ss04 = true;
      ss05 = true;
    };
    cursor_blink = false;
    tabs = {
      git_status = true;
      file_icons = true;
    };
    search = { regex = true; };
    theme = {
      mode = "dark";
      light = "One Light"; # theme doesn't work without this for some reason
      dark = "Tokyo Night Storm";
    };
    terminal = { line_height = { custom = 1; }; };
    languages = {
      nix = {
        format_on_save = true;
        language_servers = [ "nil" ];
        formatter = {
          external = {
            command = "nixfmt";
            arguments = [ ];
          };
        };
      };
    };
  };
  xdg.configFile."zed/keymap.json".text = builtins.toJSON [
    {
      context = "Editor && vim_mode == normal";
      bindings = {
        F = "editor::ToggleCodeActions";
        gh = "editor::Hover";
        tab = [ "workspace::SendKeystrokes" "ctrl-pagedown" ];
        shift-tab = [ "workspace::SendKeystrokes" "ctrl-pageup" ];
        ctrl-h = [ "workspace::ActivatePaneInDirection" "Left" ];
        ctrl-j = [ "workspace::ActivatePaneInDirection" "Down" ];
        ctrl-k = [ "workspace::ActivatePaneInDirection" "Up" ];
        ctrl-l = [ "workspace::ActivatePaneInDirection" "Right" ];
      };
    }
    {
      context = "Dock";
      bindings = {
        ctrl-h = [ "workspace::ActivatePaneInDirection" "Left" ];
        ctrl-l = [ "workspace::ActivatePaneInDirection" "Right" ];
        ctrl-k = [ "workspace::ActivatePaneInDirection" "Up" ];
        ctrl-j = [ "workspace::ActivatePaneInDirection" "Down" ];
      };
    }
    {
      context = "Editor && (showing_code_actions || showing_completions)";
      bindings = {
        tab = "editor::ContextMenuNext";
        shift-tab = "editor::ContextMenuPrev";
      };
    }
    {
      context = "Editor && vim_mode == insert";
      bindings = { "j k" = [ "workspace::SendKeystrokes" "escape" ]; };
    }
  ];
}
