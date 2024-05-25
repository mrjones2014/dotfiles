{ inputs, isLinux, ... }: {
  imports = [ inputs.arkenfox.hmModules.default ];
  programs.firefox = {
    enable = isLinux;
    arkenfox = {
      enable = true;
      version = "118.0";
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

    profiles.Default.arkenfox = {
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
}
