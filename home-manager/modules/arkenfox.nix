{ inputs, isLinux, ... }: {
  imports = [ inputs.arkenfox.hmModules.default ];
  programs.firefox = {
    enable = isLinux;
    arkenfox = {
      enable = true;
      version = "118.0";
    };
    policies = {
      DisableTelemetry = true;
      DisablePocket = true;

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
