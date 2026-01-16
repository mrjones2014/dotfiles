{ config, ... }:
{
  system.defaults = {
    screencapture = {
      # store screenshots in ~/Downloads by default
      location = "${config.users.users.mat.home}/Downloads";
      # only copy screenshots to clipboard by default
      target = "clipboard";
    };
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleInterfaceStyleSwitchesAutomatically = false;
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
      NewWindowTarget = "Home";
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
    CustomUserPreferences = {
      # Set unicode hex input as an input source
      # so my qmk firmware can send unicode inputs
      "com.apple.HIToolbox" = {
        # Add Unicode Hex Input to input sources
        AppleEnabledInputSources = [
          {
            "InputSourceKind" = "Keyboard Layout";
            "KeyboardLayout Name" = "Unicode Hex Input";
            "KeyboardLayout ID" = 0;
          }
        ];
        # Optionally, select it as the active input source
        AppleSelectedInputSources = [
          {
            "InputSourceKind" = "Keyboard Layout";
            "KeyboardLayout Name" = "Unicode Hex Input";
            "KeyboardLayout ID" = 0;
          }
        ];
      };
    };

  };
}
