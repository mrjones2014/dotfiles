#modified from: https://github.com/NixOS/nixpkgs/issues/137698#issuecomment-2404192700
{
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      extraConfig = ''
        [main]
        # Bind both Super keys to trigger the 'macmeta' layer
        leftmeta = layer(macmeta)
        rightmeta = layer(macmeta)

        # Default behavior: pass through as Super+key, except for explicit mappings
        [macmeta:M]
        # Copy
        c = C-insert
        # Paste
        v = S-insert
        # Cut
        x = S-delete
        # Undo
        z = C-z
        # Redo
        y = C-y
        # Select All
        a = C-a
        # Save
        s = C-s
        # Open
        o = C-o
        # New
        n = C-n
        # Quit
        q = C-q

        # Find
        f = C-f
        # New Tab
        # FIXME: this conflicts with my Super+T Zellij keybind
        # t = C-t
        # Close Tab/Window
        w = C-w
        # Refresh/Reload
        r = C-r

        # Alternative Redo
        shift+z = C-S-z
        # Reopen Closed Tab
        shift+t = C-S-t
        # New Private/Incognito Window
        shift+n = C-S-n

        # Tab switching - keep as Alt+number
        1 = A-1
        2 = A-2
        3 = A-3
        4 = A-4
        5 = A-5
        6 = A-6
        7 = A-7
        8 = A-8
        9 = A-9

        # Move cursor to beginning of line
        left = home
        # Move cursor to end of line
        right = end

        # App switching
        tab = swapm(app_switch_state, A-tab)

        [app_switch_state:A]
      '';
    };
  };
}
