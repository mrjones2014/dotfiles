# NOTE: modified from https://github.com/NixOS/nixpkgs/issues/273556

# Download LLMs per api
# curl http://localhost:11434/api/pull -d '{ "name": "llama2" }'
{ pkgs, ... }:

let
  open-webui-static = pkgs.buildNpmPackage {
    pname = "open-webui";
    version = "0.0.1";

    src = pkgs.fetchFromGitHub {
      owner = "open-webui";
      repo = "open-webui";
      rev = "76a788939f92a7a7d9705f971b9ce6e27b249d31";
      sha256 = "sha256-MWgERNvg3FX1N6GD11Zl27Ni/tuEoRyYNWPiLiHst2M=";
    };
    npmDepsHash = "sha256-TavFWEROSXS3GKbMzKhblLYLuN1tpXzlJG0Tm5p6fMI=";

    PUBLIC_API_BASE_URL = "http://localhost:11434/api";

    # Ollama URL for the backend to connect
    # The path '/ollama/api' will be redirected to the specified backend URL
    OLLAMA_API_BASE_URL = "http://localhost:11434/api";
    # npm run build creates a static "build" folder.
    installPhase = ''
      cp -R ./build $out
    '';
  };
  open-webui = pkgs.writeShellScriptBin "open-webui" ''
    # cors: allow broswer to make requests to ollama on different port than website
    ${pkgs.nodePackages.http-server}/bin/http-server ${open-webui-static} --cors='*' --port 8080
  '';
in {
  # create a Linux user that will run ollama
  # and has access rights to store LLM files.
  users.users.ollama = {
    name = "ollama";
    group = "ollama";
    description = "Ollama user";
    isSystemUser = true;
  };
  # suggested by nix build, no idea why
  users.groups.ollama = { };
  systemd.services.open-webui = {
    description = "Ollama WebUI Service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    enable = true;

    serviceConfig = {
      ExecStart = "${open-webui}/bin/open-webui";
      # DynamicUser = "true";
      User = "ollama";
      Type = "simple";
      Restart = "always";
      # RestartSec = 3;
      # KillMode = "process";
    };
  };
}
