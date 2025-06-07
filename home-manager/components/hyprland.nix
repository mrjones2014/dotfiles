{
  pkgs,
  isThinkpad,
  ...
}:
let
  wallpaperImg = pkgs.fetchurl {
    url = "https://w.wallhaven.cc/full/z8/wallhaven-z8g6wv.jpg";
    hash = "sha256-AJLXmM86rnuoT0I93ewFocxFKwikIOt1h+JDOmWzQzg=";
  };
  anyrun_plugin = plug: "${pkgs.anyrun}/lib/lib${plug}.so";
in
{
  home.packages = with pkgs; [
    pavucontrol
    playerctl
    brightnessctl
    networkmanagerapplet
    nwg-dock-hyprland
    hyprshot
    nerd-fonts.symbols-only
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor =
        if isThinkpad then
          [ ",preferred,auto,1" ]
        else
          [
            "DP-2,5120x1440@144,0x1440,1" # LG 49" (Primary) - bottom
            "DP-3,3440x1440@100,1680x0,1" # Sceptre 35" - top right
            "HDMI-1,2560x1440@60,5120x320,1,transform,3" # ViewSonic 24" - right side, portrait
          ];
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = false;
        };
        sensitivity = 0;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
        allow_tearing = false;
      };

      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Window rules for GNOME-like behavior
      windowrulev2 = [
        "float,class:^(pavucontrol)$"
        "float,class:^(nm-applet)$"
        "float,class:^(org.gnome.Settings)$"
        "size 800 600,class:^(org.gnome.Settings)$"
      ];

      # Key bindings
      "$mod" = "SUPER";
      bind = [
        # App launcher (GNOME-like search)
        "$mod, SPACE, exec, anyrun"

        # Terminal
        "$mod, Return, exec, ghostty"

        # File manager
        "$mod, E, exec, nautilus"

        # Close window
        "$mod, Q, killactive"

        # Exit Hyprland
        "$mod SHIFT, E, exit"

        # Float/tile toggle
        "$mod, V, togglefloating"

        # Fullscreen
        "$mod, F, fullscreen"

        # Window focus
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # Move windows
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, J, movewindow, d"

        # Workspace switching
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Window tiling (similar to your GTile setup)
        "$mod CTRL ALT, L, resizeactive, 66% 100%" # Right 2/3
        "$mod CTRL ALT, H, resizeactive, 33% 100%" # Left 1/3
        "$mod CTRL ALT, K, resizeactive, 66% 100%" # Center 2/3

        # Screenshot
        ", Print, exec, hyprshot -m region"
        "$mod, Print, exec, hyprshot -m window"

        # Volume control
        ", XF86AudioRaiseVolume, exec, playerctl volume 0.05+"
        ", XF86AudioLowerVolume, exec, playerctl volume 0.05-"
        ", XF86AudioMute, exec, playerctl volume 0"

        # Brightness control
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
      exec-once = [
        "waybar"
        "hyprpaper"
        "nm-applet"
        "nwg-dock-hyprland"
      ];
    };
  };

  programs = {
    hyprlock.enable = true;

    waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          spacing = 4;

          modules-left = [
            "hyprland/workspaces"
            "hyprland/window"
          ];
          modules-center = [ "clock" ];
          modules-right = [
            "pulseaudio"
            "network"
            "battery"
            "tray"
          ];

          "hyprland/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
            format = "{icon}";
            format-icons = {
              "1" = "";
              "2" = "";
              "3" = "";
              "4" = "";
              "5" = "";
              urgent = "";
              focused = "";
              default = "";
            };
          };

          "hyprland/window" = {
            format = "{}";
            max-length = 50;
          };

          clock = {
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format-alt = "{:%Y-%m-%d}";
          };

          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-plugged = "{capacity}% ";
            format-alt = "{time} {icon}";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
          };

          network = {
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ipaddr}/{cidr} ";
            tooltip-format = "{ifname} via {gwaddr} ";
            format-linked = "{ifname} (No IP) ";
            format-disconnected = "Disconnected ⚠";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
          };

          pulseaudio = {
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [
                ""
                ""
                ""
              ];
            };
            on-click = "pavucontrol";
          };

          tray = {
            spacing = 10;
          };
        };
      };

      style = ''
        * {
          font-family: "Inter", sans-serif;
          font-size: 13px;
        }

        window#waybar {
          background-color: rgba(43, 48, 59, 0.9);
          border-bottom: 3px solid rgba(100, 114, 125, 0.5);
          color: #ffffff;
          transition-property: background-color;
          transition-duration: 0.5s;
        }

        button {
          box-shadow: inset 0 -3px transparent;
          border: none;
          border-radius: 0;
        }

        #workspaces button {
          padding: 0 5px;
          background-color: transparent;
          color: #ffffff;
        }

        #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
        }

        #workspaces button.focused {
          background-color: #64727d;
          box-shadow: inset 0 -3px #ffffff;
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #disk,
        #temperature,
        #backlight,
        #network,
        #pulseaudio,
        #tray {
          padding: 0 10px;
          color: #ffffff;
        }
      '';
    };

    anyrun = {
      enable = true;
      config = {
        plugins = [
          (anyrun_plugin "applications")
          (anyrun_plugin "websearch")
          (anyrun_plugin "rink")
          (anyrun_plugin "symbols")
        ];

        width.fraction = 0.3;
        y.absolute = 15;
        hidePluginInfo = true;
        closeOnClick = true;
      };
      extraConfigFiles."websearch.ron".text = ''
        Config(
          prefix: "",
          engines: [
            Custom(
              name: "Kagi",
              url: "https://kagi.com/search?q={}"
            )
          ]
        )
      '';
    };
  };

  services = {
    hyprpolkitagent.enable = true;
    hypridle.enable = true;
    hyprpaper = {
      enable = true;
      settings = {
        preload = [ "${wallpaperImg}" ];
        wallpaper = [ ",${wallpaperImg}" ];
      };
    };
  };

  home.file.".config/nwg-dock-hyprland/config.json".text = builtins.toJSON {
    output = "DP-2";
    position = "bottom";
    icon_size = 48;
    auto_hide = true;
    items = [
      {
        name = "Settings";
        exec = "gnome-control-center";
        icon = "org.gnome.Settings";
      }
      {
        name = "Files";
        exec = "nautilus";
        icon = "org.gnome.Nautilus";
      }
      {
        name = "Spotify";
        exec = "spotify";
        icon = "spotify";
      }
      {
        name = "Zen Browser";
        exec = "zen-beta";
        icon = "zen-beta";
      }
      {
        name = "Terminal";
        exec = "ghostty";
        icon = "com.mitchellh.ghostty";
      }
      {
        name = "Notes";
        exec = "standard-notes";
        icon = "standard-notes";
      }
      {
        name = "1Password";
        exec = "1password";
        icon = "1password";
      }
      {
        name = "Signal";
        exec = "signal-desktop";
        icon = "signal";
      }
      {
        name = "Discord";
        exec = "vesktop";
        icon = "vesktop";
      }
      {
        name = "Steam";
        exec = "steam";
        icon = "steam";
      }
    ];
  };
}
