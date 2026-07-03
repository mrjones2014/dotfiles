let
  share_settings = {
    browseable = "yes";
    writable = "yes";
    public = "yes";
    "read only" = "no";
    "force user" = "nobody";
    "force group" = "users";
    "force directory mode" = "2770";
  };
in
{
  # these are NOT exposed to the internet
  services = {
    # samba share, allow guest users full access
    # it's only reachable via LAN anyway
    samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "guest account" = "nobody";
          "map to guest" = "Bad User";
          "load printers" = "no";
          "printcap name" = "/dev/null";
          # Needed to load PS2 games with OPL
          "server min protocol" = "NT1";
          "ntlm auth" = "yes";
        };
        fileshare = {
          path = "/export/fileshare";
        }
        // share_settings;
        PS2_Games = {
          path = "/export/PS2_Games";
        }
        // share_settings;
      };
    };
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };
}
