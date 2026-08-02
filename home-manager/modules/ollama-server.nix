{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.ollama-server;
  ollamaHost = "${cfg.host}:${toString cfg.port}";
  ollama = if pkgs.stdenv.isDarwin then "${ollamaApp}" else "${pkgs.ollama}/bin/ollama";
  ollamaApp = pkgs.writeShellScript "ollama-app" ''
    if [ -x /Applications/Ollama.app/Contents/Resources/ollama ]; then
      exec /Applications/Ollama.app/Contents/Resources/ollama "$@"
    fi

    echo "Ollama.app is required for MLX models on Darwin" >&2
    exit 127
  '';

  serverArgs = [
    ollama
    "serve"
  ];

  pullModels = pkgs.writeShellScript "ollama-pull-models" ''
    set -eu

    export OLLAMA_HOST=${lib.escapeShellArg ollamaHost}

    ready=false
    for _ in $(seq 1 30); do
      if ${ollama} list >/dev/null 2>&1; then
        ready=true
        break
      fi
      sleep 1
    done

    if [ "$ready" != true ]; then
      echo "ollama server did not become ready" >&2
      exit 1
    fi

    for model in ${lib.escapeShellArgs cfg.models}; do
      ${ollama} pull "$model"
    done
  '';
in
{
  options.services.ollama-server = {
    enable = lib.mkEnableOption "Ollama HTTP server";

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

    models = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "qwen2.5:0.5b-instruct-q4_K_M"
        "qwen3.5:4b-mlx"
      ];
      description = "Ollama models to pull after the server starts.";
    };

    defaultModel = lib.mkOption {
      type = lib.types.str;
      default = "qwen2.5:0.5b-instruct-q4_K_M";
      description = "Default Ollama model for local clients.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = builtins.elem cfg.defaultModel cfg.models;
            message = "services.ollama-server.defaultModel must be listed in services.ollama-server.models.";
          }
        ];

        home = {
          # install the homebrew cask on darwin, nixpkgs version is missing a dependency
          packages = lib.optionals (!pkgs.stdenv.isDarwin) [ pkgs.ollama ];
          sessionVariables = {
            OLLAMA_HOST = ollamaHost;
            OLLAMA_SERVER_ADDRESS = "http://${ollamaHost}";
            OLLAMA_DEFAULT_MODEL = cfg.defaultModel;
          };
        };
      }

      (lib.mkIf pkgs.stdenv.isLinux {
        systemd.user.services = {
          ollama-server = {
            Unit = {
              Description = "Ollama HTTP server";
              After = [ "network.target" ];
            };
            Install.WantedBy = [ "default.target" ];
            Service = {
              Environment = [ "OLLAMA_HOST=${ollamaHost}" ];
              ExecStart = lib.escapeShellArgs serverArgs;
              Restart = "on-failure";
              RestartSec = "5s";
            };
          };

          ollama-pull-models = {
            Unit = {
              Description = "Pull Ollama models";
              After = [ "ollama-server.service" ];
              Requires = [ "ollama-server.service" ];
            };
            Install.WantedBy = [ "default.target" ];
            Service = {
              Type = "oneshot";
              ExecStart = pullModels;
            };
          };
        };
      })

      (lib.mkIf pkgs.stdenv.isDarwin {
        launchd.agents = {
          ollama-server = {
            enable = true;
            config = {
              ProgramArguments = serverArgs;
              EnvironmentVariables = {
                OLLAMA_HOST = ollamaHost;
              };
              RunAtLoad = true;
              KeepAlive = true;
            };
          };

          ollama-pull-models = {
            enable = true;
            config = {
              ProgramArguments = [ "${pullModels}" ];
              RunAtLoad = true;
            };
          };
        };
      })
    ]
  );
}
