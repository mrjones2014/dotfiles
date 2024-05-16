{
  # these are NOT exposed to the internet
  networking.firewall.allowPing = true;
  services = {
    # samba for windows
    samba = {
      enable = true;
      openFirewall = true;
      extraConfig = ''
        guest account = nobody
        map to guest = Bad User
        load printers = no
        printcap name = /dev/null
        log file = /var/log/samba/client.%I
        log level = 2
      '';
      shares = {
        fileshare = {
          path = "/export/fileshare";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "force user" = "nobody";
          "force group" = "users";
        };
      };
    };
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
    gvfs.enable = true;
  };
}
