{ config, ... }:
let
  port = 30011;
  data_dir = "/var/lib/anythingllm";
in
{
  systemd.tmpfiles.rules = [
    "d ${data_dir} 0750 root root -"
    "f ${data_dir}/.env 0644 root root -"
  ];
  age.secrets.anythingllm_env.file = ../../secrets/anythingllm_env.age;
  virtualisation.oci-containers.containers.anythingllm = {
    image = "mintplexlabs/anythingllm:latest";
    ports = [ "${toString port}:3001" ];
    volumes = [ "${data_dir}:/app/server/storage" ];
    extraOptions = [ "--cap-add=SYS_ADMIN" ];
    environmentFiles = [ config.age.secrets.anythingllm_env.path ];
  };
  services = {
    nginx.subdomains."ai".port = port;

    # ollama.enable = true;
    # open-webui = {
    #   enable = true;
    #   environmentFile = config.age.secrets.open_webui_env.path;
    #   package = pkgs.open-webui.overrideAttrs (old: {
    #     # for https://github.com/rbb-dev/Open-WebUI-OpenRouter-pipe
    #     # see: https://github.com/NixOS/nixpkgs/issues/422030#issuecomment-3146105303
    #     propagatedBuildInputs =
    #       old.propagatedBuildInputs
    #       ++ (with pkgs.python3Packages; [
    #         aiohttp
    #         cryptography
    #         fastapi
    #         httpx
    #         lz4
    #         pydantic
    #         pydantic-core
    #         sqlalchemy
    #         tenacity
    #         pyzipper
    #         cairosvg
    #         pillow
    #       ]);
    #   });
    # };
  };
}
