{ inputs, isLinux, ... }: {
  imports = [ inputs.arkenfox.hmModules.default ];
  # TODO this doesn't work
  home.file.".local/share/gnome-shell/search-providers/firefox-search-provider.ini".text =
    ''
      [Shell Search Provider]
      DesktopId=firefox.desktop
      BusName=org.mozilla.Firefox.SearchProvider
      ObjectPath=/org/mozilla/Firefox/SearchProvider
      Version=2
    '';
  programs.firefox = {
    enable = isLinux;
    arkenfox = {
      enable = true;
      version = "118.0";
    };
    profiles.Default = {
      isDefault = true;
      search = {
        default = "Kagi";
        force = true;
        engines = {
          Kagi = {
            iconUpdateURL =
              "https://help.kagi.com/assets/kagi-logo.f29e5d62.png";
            urls = [{
              template = "https://kagi.com/search";
              params = [{
                name = "q";
                value = "{searchTerms}";
              }];
            }];
          };
          # Hide all other search engines
          "Amazon.com".metaData.hidden = true;
          Google.metaData.hidden = true;
          Bing.metaData.hidden = true;
          DuckDuckGo.metaData.hidden = true;
          eBay.metaData.hidden = true;
          "Wikipedia (en)".metaData.hidden = true;
        };
      };
      settings = {
        # disable Pocket shit
        "extensions.pocket.enabled" = false;
        "extensions.pocket.api" = "";
        "extensions.pocket.bffApi" = "";
        "browser.urlbar.suggest.pocket" = false;
        # always show bookmarks toolbar
        "browser.toolbars.bookmarks.visibility" = "always";
        # GNOME search provider
        "browser.gnome-search-provider.enabled" = true;
      };
      arkenfox = {
        enable = isLinux;
        "0000".enable = true;
        "0100".enable = true;
        "0200".enable = true;
        "0300".enable = true;
        "0400".enable = true;
        "0600".enable = true;
        "0800".enable = true;
        "0900".enable = true;
        "1200".enable = true;
        "1600".enable = true;
        "2600".enable = true;
        "2700".enable = true;
        "2800".enable = true;
      };
    };
  };
}
