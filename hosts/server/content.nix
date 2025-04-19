{
  imports = [ ./torrent_client.nix ./cleanuperr.nix ];
  services.nginx.subdomains = {
    jellyfin = 8096;
    jellyseerr = 5055;
    prowlarr = 9696;
    sonarr = 8989;
    radarr = 7878;
    bazarr = 6767;
  };
  services = {
    jellyfin = {
      enable = true;
      # see: https://jellyfin.org/docs/general/networking/index.html
      # ports are:
      # TCP: 8096, 8920
      # UDP: 1900 7359
      openFirewall = true;
    };
    # port 5055
    jellyseerr = {
      enable = true;
      openFirewall = true;
    };
    # port 9696
    prowlarr = {
      enable = true;
      openFirewall = true;
    };
    # port 8989
    sonarr = {
      enable = true;
      openFirewall = true;
    };
    # port 7878
    radarr = {
      enable = true;
      openFirewall = true;
    };
    # port 6767
    bazarr = {
      enable = true;
      openFirewall = true;
    };
  };
  # TODO remove this when this is resolved https://github.com/NixOS/nixpkgs/issues/360592
  nixpkgs.config.permittedInsecurePackages = [
    "aspnetcore-runtime-6.0.36"
    "aspnetcore-runtime-wrapped-6.0.36"
    "dotnet-sdk-6.0.428"
    "dotnet-sdk-wrapped-6.0.428"
  ];
}
