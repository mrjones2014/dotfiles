{ pkgs, config, ... }: {
  imports = [ ./gnome.nix ];
  programs.fish.enable = true;
  users.users.mat.shell = pkgs.fish;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  environment.variables = {
    SUDO_EDITOR = "nvim";
    EDITOR = "nvim";
  };

  environment.systemPackages = with pkgs; [
    steam-run
    # Discord with a system workaround for Wayland support
    # Work around https://github.com/NixOS/nixpkgs/issues/159267
    (pkgs.writeShellApplication {
      name = "discord";
      text = "${pkgs.discord}/bin/discord --use-gl=desktop";
    })
    (pkgs.makeDesktopItem {
      name = "discord";
      exec = "discord";
      desktopName = "Discord";
      icon = ./discord.png;
    })
  ];
}
