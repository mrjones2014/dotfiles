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
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisableFirefoxAccounts = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DisplayBookmarksToolbar = "always";
      SearchBar = "unified";
      ExtensionSettings = {
        # uBlock Origin:
        "uBlock0@raymondhill.net" = {
          install_url =
            "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          default_area = "navbar";
        };
        # 1Password
        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          install_url =
            "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
          installation_mode = "force_installed";
          default_area = "navbar";
        };
        # xBrowserSync
        "{019b606a-6f61-4d01-af2a-cea528f606da}" = {
          install_url =
            "https://addons.mozilla.org/firefox/downloads/latest/xbs/latest.xpi";
          installation_mode = "force_installed";
        };
        # Tokyonight theme
        "{4520dc08-80f4-4b2e-982a-c17af42e5e4d}" = {
          install_url =
            "https://addons.mozilla.org/firefox/downloads/latest/tokyo-night-milav/latest.xpi";
        };
        # Disable built-in search engines
        "amazondotcom@search.mozilla.org" = { installation_mode = "blocked"; };
        "bing.mozilla.org" = { installation_mode = "blocked"; };
        "ddg.mozilla.org" = { installation_mode = "blocked"; };
        "ebay.mozilla.org" = { installation_mode = "blocked"; };
        "google.mozilla.org" = { installation_mode = "blocked"; };
      };
    };
    profiles.Default = {
      isDefault = true;
      # tokyonight theme from extension above
      settings.activeThemeID = "{4520dc08-80f4-4b2e-982a-c17af42e5e4d}";
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
