{
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.zen-browser.homeModules.default
  ];
  programs.zen-browser = {
    enable = true;
    profiles.default = {
      settings = {
        "zen.urlbar.behavior" = "normal";
        "zen.urlbar.replace-newtab" = false;
        "zen.urlbar.use-single-toolbar" = false;
        "zen.widget.mac.mono-window-controls" = false;
        "zen.welcome-screen.seen" = true;
        "browser.toolbars.bookmarks.visibility" = "newtab";
        # I only want to use Kagi
        "browser.search.searchEnginesURL" = "";
      };
      search = {
        force = true;
        default = "Kagi";
        privateDefault = "Kagi";
        order = [ "Kagi" ];
        engines = {
          Kagi = {
            icon = "https://kagi.com/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [
              "@k"
              "@kagi"
            ];
            urls = [
              {
                template = "https://kagi.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
          };
        };
      };
    };
    policies = {
      DisableFirefoxStudies = true;
      DisableMasterPasswordCreation = true;
      DisableProfileImport = true;
      DisableProfileRefresh = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisableFormHistory = true;
      OfferToSaveLogins = false;
      SearchEngines = {
        Remove = [
          "Google"
          "Bing"
          "Amazon.com"
          "DuckDuckGo"
          "eBay"
          "Ecosia"
          "Wikipedia (en)"
        ];
      };
      ExtensionSettings =
        let
          moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
        in
        {
          "uBlock0@raymondhill.net" = {
            install_url = moz "ublock-origin";
            installation_mode = "force_installed";
            default_area = "navbar"; # pinned
          };
          "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
            install_url = moz "1password-x-password-manager";
            installation_mode = "force_installed";
            default_area = "navbar"; # pinned
          };
        };
      "3rdparty".Extensions = {
        "uBlock0@raymondhill.net".adminSettings = {
          userSettings = rec {
            uiTheme = "dark";
            cloudStorageEnabled = lib.mkForce false;

            importedLists = [
              "https:#filters.adtidy.org/extension/ublock/filters/3.txt"
              "https:#github.com/DandelionSprout/adfilt/raw/master/LegitimateURLShortener.txt"
              "https:#mjones.network/ublock-filters.txt"
            ];

            externalLists = lib.concatStringsSep "\n" importedLists;
          };

          selectedFilterLists = [
            "CZE-0"
            "adguard-generic"
            "adguard-annoyance"
            "adguard-social"
            "adguard-spyware-url"
            "easylist"
            "easyprivacy"
            "https:#github.com/DandelionSprout/adfilt/raw/master/LegitimateURLShortener.txt"
            "plowe-0"
            "ublock-abuse"
            "ublock-badware"
            "ublock-filters"
            "ublock-privacy"
            "ublock-quick-fixes"
            "ublock-unbreak"
            "urlhaus-1"
          ];
        };
      };
    };
  };
}
