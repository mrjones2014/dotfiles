# Shared stuff goes in here, and GNOME or Pantheon specific settings go in their own files
{ pkgs, config, lib, ... }:
let
  wallpaperImg = pkgs.fetchurl {
    url =
      "https://user-images.githubusercontent.com/8648891/246180692-b8144052-e947-47b0-b59c-ea1022b9b629.jpg";
    hash = "sha256-itnhNPYvQLfCULNrEZqP+3VBQVmEmvh9wv6C2F3YKQU=";
  };
  vars = (import ../../../vars.nix);
  usePantheon = vars.usePantheon;
  useGnome = vars.useGnome;
in {
  imports = [ ] ++ lib.lists.optionals usePantheon [ ./pantheon.nix ]
    ++ lib.lists.optionals useGnome [ ./gnome.nix ];

  # workaround for https://github.com/nix-community/home-manager/issues/3447
  # autostart 1Password in the background so I can use the SSH agent without manually opening the app first
  xdg.configFile."autostart/1password.desktop".text = ''
     [Desktop Entry]
    Name=1Password
    Exec=1password --silent
    Terminal=false
    Type=Application
    Icon=1password
    StartupWMClass=1Password
    Comment=Password manager and secure wallet
    MimeType=x-scheme-handler/onepassword;
    Categories=Office;
  '';

  # see  https://github.com/wimpysworld/nix-config/blob/b8a260ddea1bbf088461f7272382d99acbf86ce7/home-manager/_mixins/desktop/pantheon.nix
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      clock-show-weekday = true;
    };
    "org/gnome/desktop/background" = {
      picture-uri = "file://${wallpaperImg}";
    };
    "org/gnome/desktop/datetime" = { automatic-timezone = true; };
    "org/gnome/desktop/wm/keybindings" = {
      move-to-monitor-left = [ "<Shift><Control><Alt>h" ];
      move-to-monitor-right = [ "<Shift><Control><Alt>l" ];
      move-to-monitor-up = [ "<Shift><Control><Alt>k" ];
      move-to-monitor-down = [ "<Shift><Control><Alt>j" ];
    };
  };
  home.packages = [ pkgs.flameshot ];
  gtk = {
    gtk2 = {
      configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      extraConfig = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    gtk3 = { extraConfig = { gtk-application-prefer-dark-theme = 1; }; };
    gtk4 = { extraConfig = { gtk-application-prefer-dark-theme = 1; }; };
  };
}
