{ config, ... }: {
  system.stateVersion = 6;
  imports = [ ../../nixos-modules/nix-conf.nix ];
  nixpkgs.hostPlatform = "aarch64-darwin";
  users.users.mat = {
    name = "mat";
    home = "/Users/mat";
  };

  system.defaults = {
    screencapture = {
      # store screenshots in ~/Downloads by default
      location = "${config.users.users.mat.home}/Downloads";
      # only copy screenshots to clipboard by default
      target = "clipboard";
    };
    NSGlobalDomain = {
      # expanded save panel by default
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      # do not save to icloud by default
      NSDocumentSaveNewDocumentsToCloud = false;
      # Display ASCII control characters using caret notation in standard text views
      # Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
      NSTextShowsControlCharacters = true;
      # Disable "natural" scrolling (it should be called unnatural scrolling)
      "com.apple.swipescrolldirection" = false;
      # Trackpad: enable tap to click
      "com.apple.mouse.tapBehavior" = 1;
      # Enable full keyboard access for all controls
      # (e.g. enable Tab in modal dialogs)
      AppleKeyboardUIMode = 3;
    };
    finder = {
      AppleShowAllFiles = true;
      AppleShowAllExtensions = true;
      ShowPathbar = true;
    };
    dock = {
      show-process-indicators = false;
      show-recents = false;
      # Don't show dashboard as a space
      dashboard-in-overlay = true;
      # Don't rearrange spaces based on most recently used
      mru-spaces = false;
      autohide = true;
      # Disable all hot corners
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
      wvous-bl-corner = 1;
      wvous-br-corner = 1;
    };
    ActivityMonitor = {
      OpenMainWindow = true;
      # show CPU usage graph on icon
      IconType = 5;
      # Show all processes
      ShowCategory = 100;
    };
  };
}
