{ config, pkgs, ... }:
{
  age.secrets.open_webui_env.file = ../../secrets/open_webui.age;
  services = {
    nginx.subdomains."ai".port = config.services.open-webui.port;
    ollama.enable = true;
    open-webui = {
      enable = true;
      environmentFile = config.age.secrets.open_webui_env.path;
      package = pkgs.open-webui.overrideAttrs (old: {
        # for https://github.com/rbb-dev/Open-WebUI-OpenRouter-pipe
        # see: https://github.com/NixOS/nixpkgs/issues/422030#issuecomment-3146105303
        propagatedBuildInputs =
          old.propagatedBuildInputs
          ++ (with pkgs.python3Packages; [
            aiohttp
            cryptography
            fastapi
            httpx
            lz4
            pydantic
            pydantic-core
            sqlalchemy
            tenacity
            pyzipper
            cairosvg
            pillow
          ]);
      });
    };
  };
}
