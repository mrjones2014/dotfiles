{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.llama-server;
  # preload qwen, mostly this will be used for title generation
  model = pkgs.fetchurl {
    url = "https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf";
    hash = "sha256-dKTajJ/bzRW9H20B1iFBDTHG/ACYb162h4JOe5PXqds=";
  };

  serverArgs = [
    "${pkgs.llama-cpp}/bin/llama-server"
    "--model"
    "${model}"
    "--host"
    cfg.host
    "--port"
    (toString cfg.port)
    "--ctx-size"
    "2048"
    "--log-disable"
  ];
in
{
  options.services.llama-server = {
    enable = lib.mkEnableOption "llama.cpp HTTP server";

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host address to bind the server to.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 11434;
      description = "Port to listen on.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home = {
          packages = [ pkgs.llama-cpp ];
          sessionVariables = {
            LLAMA_SERVER_ADDRESS = "http://${config.services.llama-server.host}:${toString config.services.llama-server.port}";
            LLAMA_DEFAULT_MODEL = "qwen2.5-0.5b-instruct-q4_k_m";
          };
        };
      }

      (lib.mkIf pkgs.stdenv.isLinux {
        systemd.user.services.llama-server = {
          Unit = {
            Description = "llama.cpp HTTP server (Qwen2.5-1.5B)";
            After = [ "network.target" ];
          };
          Install.WantedBy = [ "default.target" ];
          Service = {
            ExecStart = lib.escapeShellArgs serverArgs;
            Restart = "on-failure";
            RestartSec = "5s";
          };
        };
      })

      (lib.mkIf pkgs.stdenv.isDarwin {
        launchd.agents.llama-server = {
          enable = true;
          config = {
            ProgramArguments = serverArgs;
            RunAtLoad = true;
            KeepAlive = true;
          };
        };
      })
    ]
  );
}
