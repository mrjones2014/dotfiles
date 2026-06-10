{ osConfig, pkgs, ... }:
let
  op_sudo_password_script = pkgs.writeShellScriptBin "opsudo" ''
    PASSWORD="$(op read "op://Private/System Password/password" --account 3UBYV6PWJZAS7HTEKHDSQ7HPUA)"
    if [[ -z "$PASSWORD" ]]; then
      echo "Failed to get password from 1Password."
      read -r -s -p "󰌾 Password: " PASSWORD
    fi

    echo "$PASSWORD"
  '';
in
{
  # If we install `op` via `home.packages`, on Linux it will not
  # be able to connect to the 1Password desktop app.
  # The NixOS/nix-darwin module does some workarounds to make sure this works.
  assertions = [
    {
      assertion = osConfig.programs._1password.enable;
      message = "`programs._1password.enable` must be set to use 1Password shell utilities.";
    }
  ];

  home.packages = [
    pkgs.gh-1p
  ];

  home.sessionVariables = {
    SUDO_ASKPASS = "${op_sudo_password_script}/bin/opsudo";
    # for `programs.nh`: https://github.com/nix-community/nh#nh-specific
    NH_SUDO_ASKPASS = "${op_sudo_password_script}/bin/opsudo";
  };
  programs.fish.shellAliases.sudo = "sudo -A";
}
