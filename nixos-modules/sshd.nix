{
  services = {
    fail2ban.enable = true;
    openssh = {
      enable = true;
      settings = {
        # only allow SSH key auth
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "mat" ];
      };
    };
  };

  user.users.mat.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDsT6GLG7sY8YKX7JM+jqS3EAti3YMzwHKWViveqkZvu"
  ];
}
