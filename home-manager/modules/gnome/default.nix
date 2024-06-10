{
  imports = [ ./dconf.nix ];
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
  # autostart Signal
  xdg.configFile."autostart/signal-desktop.desktop".text = ''
    [Desktop Entry]
    Name=Signal
    Exec=signal-desktop --no-sandbox --start-in-tray %U
    Terminal=false
    Type=Application
    Icon=signal-desktop
    StartupWMClass=Signal
    Comment=Private messaging from your desktop
    MimeType=x-scheme-handler/sgnl;x-scheme-handler/signalcaptcha;
    Categories=Network;InstantMessaging;Chat;
  '';
  gtk.enable = true;
}
