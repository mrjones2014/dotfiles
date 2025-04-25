let trilium_port = 9632; trilium_data = "/var/lib/trilium"; in {
  systemd.tmpfiles.rules = [ "d ${trilium_data} 0750 root root -" ];
  services.nginx.subdomains.trilium = trilium_port;
  virtualisation.oci-containers.containers.trilium = {
    autoStart = true;
    image = "ghcr.io/triliumnext/notes:latest";
    ports = [ "${toString trilium_port}:${toString trilium_port}" ];
    volumes = [ "${trilium_data}:/home/node/trilium-data" ];
    environment = {
      TRILIUM_NETWORK_HOST = "0.0.0.0";
      TRILIUM_NETWORK_PORT = toString trilium_port;
    };
  };
}
