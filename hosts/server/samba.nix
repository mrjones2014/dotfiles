{
  networking.firewall.allowPing = true;
  services = {
    samba = {
      enable = true;
      securityType = "user";
      openFirewall = true;
      extraConfig = ''
        hosts allow = 192.168. 127.0.0.1 localhost
        hosts deny = 0.0.0.0/0
        browseable = yes
      '';
      shares = {
        jellyfin = {
          path = "/mnt/jellyfin";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
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
