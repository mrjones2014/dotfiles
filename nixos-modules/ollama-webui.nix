# NOTE: modified from https://github.com/NixOS/nixpkgs/issues/273556

# Download LLMs per api
# curl http://localhost:11434/api/pull -d '{ "name": "llama2" }'
{ pkgs, ... }:

let
  ollama-webui-static = pkgs.buildNpmPackage {
    pname = "ollama-webui";
    version = "0.0.1";

    src = pkgs.fetchFromGitHub {
      owner = "ollama-webui";
      repo = "ollama-webui";
      rev = "970a71354b5dabc48862731dae2a0bfef733bfa9";
      sha256 = "5cHxHh2rHk/WGw8XyroKqCBG1Do+GnTvkgnX711bPEQ=";
      # hash = "sha256-noidea2er";
    };
    npmDepsHash = "sha256-N+wyvyKqsDfUqv3TQbxjuf8DF0uEJ7OBrwdCnX+IMZ4=";

    PUBLIC_API_BASE_URL = "http://localhost:11434/api";

    # Ollama URL for the backend to connect
    # The path '/ollama/api' will be redirected to the specified backend URL
    OLLAMA_API_BASE_URL = "http://localhost:11434/api";
    # npm run build creates a static "build" folder.
    installPhase = ''
      cp -R ./build $out
    '';
    # meta = with pkgs.stdenv.lib; {
    #   homepage = "https://github.com/my-username/my-repo";
    #   description = "ChatGPT-Style Web Interface for Ollama";
    #   license = licenses.mit;
    #   # maintainers = [ maintainers.john ];
    # };
  };
  ollama-webui = pkgs.writeShellScriptBin "ollama-webui" ''
    # cors: allow broswer to make requests to ollama on different port than website
    ${pkgs.nodePackages.http-server}/bin/http-server ${ollama-webui-static} --cors='*' --port 8080
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
  systemd.services.ollama-webui = {
    description = "Ollama WebUI Service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    enable = true;

    serviceConfig = {
      ExecStart = "${ollama-webui}/bin/ollama-webui";
      # DynamicUser = "true";
      User = "ollama";
      Type = "simple";
      Restart = "always";
      # RestartSec = 3;
      # KillMode = "process";
    };
  };
}
