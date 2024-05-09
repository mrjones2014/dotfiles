{ inputs, ... }: {
  imports = [ inputs.arkenfox.hmModules.default ];
  programs.firefox = {
    enable = true;
    arkenfox = {
      enable = true;
      version = "118.0";
    };

    profiles.Default.arkenfox = {
      enable = true;
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
