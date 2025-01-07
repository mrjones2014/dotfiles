{
  imports = [
    # port 8112
    ./deluge.nix
    # port 8082
    ./homepage.nix
    ./cleanuperr.nix
  ];
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
