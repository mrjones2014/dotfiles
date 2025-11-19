# verify VPN connectivity interactively with
# sudo nixos-container root-login qbittorrent-vpn
# curl https://am.i.mullvad.net/connected
{
  config,
  isServer,
  ...
}:
let
  qbittorrent_port = 8080;
  containerDataDir = if isServer then "/mnt/jellyfin" else "/mnt/storage/OtherGames";
in
{
  imports = [
    (import ./server.nix { inherit qbittorrent_port; })
    ./desktop.nix
  ];

  containers.qbittorrent-vpn = {
    autoStart = true;
    ephemeral = false;

    privateNetwork = true;
    hostAddress = "192.168.200.1";
    localAddress = "192.168.200.2";

    bindMounts = {
      "/data" = {
        hostPath = containerDataDir;
        isReadOnly = false;
      };
      "/var/lib/qBittorrent/.config" = {
        hostPath = "/var/lib/qbittorrent-vpn/config";
        isReadOnly = false;
      };
      "/var/lib/qBittorrent/.local" = {
        hostPath = "/var/lib/qbittorrent-vpn/local";
        isReadOnly = false;
      };
      "/etc/wireguard/mullvad.conf" = {
        hostPath = config.age.secrets.mullvad_wireguard.path;
        isReadOnly = true;
      };
    };

    config =
      { pkgs, ... }:
      {
        system.stateVersion = config.system.stateVersion;

        networking = {
          firewall = {
            enable = true;
            allowedTCPPorts = [ qbittorrent_port ];
          };
          useDHCP = false;
          useHostResolvConf = false;
          resolvconf.enable = true; # Enable resolvconf for wg-quick DNS management
          # Fallback DNS (Cloudflare) - used before VPN is up
          # WireGuard will prepend Mullvad DNS (10.64.0.1) when connected
          nameservers = [
            "1.1.1.1"
            "1.0.0.1"
          ];
        };

        # DNS is managed dynamically:
        # - Before VPN: Cloudflare DNS (1.1.1.1, 1.0.0.1) via eth0
        # - After VPN: Mullvad DNS (10.64.0.1) prepended by wg-quick via resolvconf

        # WireGuard configuration
        networking.wg-quick.interfaces.wg0 = {
          autostart = true;
          configFile = "/etc/wireguard/mullvad.conf";
          # Let WireGuard manage DNS (Mullvad config includes DNS = 10.64.0.1)
          # dns setting will be read from the config file

          # Post-up script to verify VPN connectivity
          postUp = ''
            # Wait for interface to be ready
            sleep 2

            # Test connectivity through VPN
            echo "Testing VPN connectivity..." | ${pkgs.systemd}/bin/systemd-cat -t vpn-check -p info

            if ${pkgs.curl}/bin/curl --max-time 10 -s https://am.i.mullvad.net/connected | ${pkgs.gnugrep}/bin/grep -q "You are connected"; then
              echo "✓ VPN connection verified - traffic is routed through Mullvad" | ${pkgs.systemd}/bin/systemd-cat -t vpn-check -p info
            else
              echo "✗ VPN verification FAILED - stopping qBittorrent for safety" | ${pkgs.systemd}/bin/systemd-cat -t vpn-check -p err
              ${pkgs.systemd}/bin/systemctl stop qbittorrent-nox.service
              exit 1
            fi
          '';

          preDown = ''
            # Stop qBittorrent before bringing down VPN
            ${pkgs.systemd}/bin/systemctl stop qbittorrent-nox.service || true
          '';
        };

        # Kill switch: ensure all traffic goes through VPN
        networking.firewall.extraCommands = ''
          # Default policy: drop everything
          iptables -P OUTPUT DROP
          iptables -P INPUT DROP
          iptables -P FORWARD DROP

          # Allow loopback
          iptables -A INPUT -i lo -j ACCEPT
          iptables -A OUTPUT -o lo -j ACCEPT

          # Allow established connections
          iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
          iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

          # Allow traffic to/from host (for container management)
          iptables -A INPUT -s 192.168.200.1 -j ACCEPT
          iptables -A OUTPUT -d 192.168.200.1 -j ACCEPT

          # Allow WireGuard traffic (before wg0 exists)
          iptables -A OUTPUT -o eth0 -p udp --dport 51820 -j ACCEPT
          iptables -A INPUT -i eth0 -p udp --sport 51820 -j ACCEPT

          # Allow DNS to Cloudflare through eth0 (before VPN is up)
          iptables -A OUTPUT -o eth0 -d 1.1.1.1 -p udp --dport 53 -j ACCEPT
          iptables -A OUTPUT -o eth0 -d 1.0.0.1 -p udp --dport 53 -j ACCEPT
          iptables -A OUTPUT -o eth0 -d 1.1.1.1 -p tcp --dport 53 -j ACCEPT
          iptables -A OUTPUT -o eth0 -d 1.0.0.1 -p tcp --dport 53 -j ACCEPT

          # Allow all traffic through VPN interface ONLY IF interface exists
          # This ensures traffic can't flow if VPN is down
          # This includes DNS to Mullvad (10.64.0.1) and all other VPN traffic
          iptables -A INPUT -i wg0 -j ACCEPT
          iptables -A OUTPUT -o wg0 -j ACCEPT
        '';

        # Ensure no default route exists outside VPN
        networking.firewall.extraStopCommands = ''
          # Reset to ACCEPT when firewall stops (for shutdown/maintenance)
          iptables -P OUTPUT ACCEPT
          iptables -P INPUT ACCEPT
          iptables -P FORWARD ACCEPT
        '';

        # qBittorrent service
        services.qbittorrent = {
          enable = true;
          openFirewall = true;
          webuiPort = qbittorrent_port;
          user = "qbittorrent";
          group = "qbittorrent";
          serverConfig = {
            BitTorrent.Session = {
              DefaultSavePath = "/data";
              TempPath = "/data/incomplete";
              TempPathEnabled = true;
            };
          };
        };
        systemd = {
          # Make qBittorrent depend on VPN being up
          services.qbittorrent-nox = {
            after = [ "wg-quick-wg0.service" ];
            requires = [ "wg-quick-wg0.service" ];

            # Additional connectivity check before starting
            preStart = ''
              echo "Verifying VPN before starting qBittorrent..." | ${pkgs.systemd}/bin/systemd-cat -t qbittorrent -p info

              # Wait up to 30 seconds for VPN
              for i in {1..30}; do
                if ${pkgs.curl}/bin/curl --max-time 5 -s https://am.i.mullvad.net/connected | ${pkgs.gnugrep}/bin/grep -q "You are connected"; then
                  echo "✓ VPN verified, starting qBittorrent" | ${pkgs.systemd}/bin/systemd-cat -t qbittorrent -p info
                  exit 0
                fi
                echo "Waiting for VPN... ($i/30)" | ${pkgs.systemd}/bin/systemd-cat -t qbittorrent -p info
                sleep 1
              done

              echo "✗ VPN verification timeout - refusing to start qBittorrent" | ${pkgs.systemd}/bin/systemd-cat -t qbittorrent -p err
              exit 1
            '';
          };

          # Periodic VPN check (every 5 minutes)
          services.vpn-connectivity-check = {
            description = "Periodic VPN connectivity verification";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = pkgs.writeShellScript "check-vpn" ''
                # Check if wg0 interface exists
                if ! ${pkgs.iproute2}/bin/ip link show wg0 &>/dev/null; then
                  echo "✗ wg0 interface is DOWN - stopping qBittorrent" | ${pkgs.systemd}/bin/systemd-cat -t vpn-monitor -p err
                  ${pkgs.systemd}/bin/systemctl stop qbittorrent-nox.service
                  exit 1
                fi

                # Check VPN connectivity
                if ${pkgs.curl}/bin/curl --max-time 10 -s https://am.i.mullvad.net/connected | ${pkgs.gnugrep}/bin/grep -q "You are connected"; then
                  echo "✓ VPN connectivity check passed" | ${pkgs.systemd}/bin/systemd-cat -t vpn-monitor -p info
                else
                  echo "✗ VPN connectivity check FAILED - stopping qBittorrent" | ${pkgs.systemd}/bin/systemd-cat -t vpn-monitor -p err
                  ${pkgs.systemd}/bin/systemctl stop qbittorrent-nox.service
                  exit 1
                fi
              '';
            };
          };

          timers.vpn-connectivity-check = {
            description = "Timer for periodic VPN connectivity checks";
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnBootSec = "5min";
              OnUnitActiveSec = "5min";
            };
          };
        };

        users.users.qbittorrent = {
          isSystemUser = true;
          group = "qbittorrent";
        };
        users.groups.qbittorrent = { };

        environment.systemPackages = with pkgs; [
          curl
          wireguard-tools
        ];
      };
  };

  # Host configuration - port forwarding
  networking.nat = {
    enable = isServer; # Only enable NAT on server
    internalInterfaces = [ "ve-qbittorrent-vpn" ];
    externalInterface = "enp0s31f6"; # homelab interface

    forwardPorts = [
      {
        destination = "192.168.200.2:${toString qbittorrent_port}";
        sourcePort = qbittorrent_port;
        proto = "tcp";
      }
    ];
  };

  # Create config directories on host
  systemd.tmpfiles.rules = [
    "d /var/lib/qbittorrent-vpn 0755 root root - -"
    "d /var/lib/qbittorrent-vpn/config 0755 root root - -"
    "d /var/lib/qbittorrent-vpn/local 0755 root root - -"
  ];

  # Automatic migration from old OCI container config
  system.activationScripts.migrateQbittorrentConfig = {
    text = ''
      OLD_CONFIG="/var/lib/qbittorrentvpn"
      NEW_CONFIG="/var/lib/qbittorrent-vpn"

      # Only migrate if old config exists and new config is empty
      if [ -d "$OLD_CONFIG" ] && [ ! -f "$NEW_CONFIG/.migrated" ]; then
        echo "Migrating qBittorrent configuration from OCI container..."

        # Migrate qBittorrent config directory
        if [ -d "$OLD_CONFIG/config/qBittorrent" ]; then
          echo "  Copying qBittorrent config..."
          mkdir -p "$NEW_CONFIG/config"
          cp -a "$OLD_CONFIG/config/qBittorrent" "$NEW_CONFIG/config/"
        fi

        # Migrate qBittorrent data/state directory
        if [ -d "$OLD_CONFIG/data/.local/share/qBittorrent" ]; then
          echo "  Copying qBittorrent state data..."
          mkdir -p "$NEW_CONFIG/local/share"
          cp -a "$OLD_CONFIG/data/.local/share/qBittorrent" "$NEW_CONFIG/local/share/"
        fi

        # Mark migration as complete
        touch "$NEW_CONFIG/.migrated"
        echo "Migration complete!"
      elif [ -f "$NEW_CONFIG/.migrated" ]; then
        echo "qBittorrent config already migrated, skipping."
      else
        echo "No old qBittorrent config found at $OLD_CONFIG, skipping migration."
      fi
    '';
    deps = [ ];
  };

  # Firewall rules on host
  networking.firewall = {
    trustedInterfaces = [ "ve-qbittorrent-vpn" ];
    allowedTCPPorts = [ qbittorrent_port ];
  };
}
