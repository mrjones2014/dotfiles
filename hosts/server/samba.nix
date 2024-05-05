{
  networking.firewall.allowPing = true;
  services = {
    samba = {
      enable = true;
      securityType = "user";
      openFirewall = true;
      extraConfig = ''
        workgroup = WORKGROUP
        server string = smbnix
        netbios name = smbnix
        security = user
        # note: localhost is the ipv6 localhost ::1
        hosts allow = 192.168. 127.0.0.1 localhost
        hosts deny = 0.0.0.0/0
        guest account = nobody
        map to guest = bad user
      '';
      shares = {
        jellyfin = {
          path = "/mnt/jellyfin";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "nobody";
          "force group" = "groupname";
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
