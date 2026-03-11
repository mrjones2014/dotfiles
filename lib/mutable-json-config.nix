# Some apps expect to have their config files be writable (e.g. Vicinae, OpenCode for MCP server auth)
# so for this, we use home-manager activationScripts to merge the resultant config file with the nix-managed
# config file; nix-managed settings take precedence to ensure our home-manager config is always applied.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  name,
  target,
  managed,
  mode ? "0600",
  mergeExpr ? ".[0] * .[1]",
}:
let
  managedFile = pkgs.writeText "${name}-managed.json" (builtins.toJSON managed);
  jq = "${pkgs.jq}/bin/jq";
  cfg = "${config.xdg.configHome}/${lib.removePrefix "/" target}";
in
{
  home.activation."merge-${name}-json" = lib.hm.dag.entryAfter [ "writeBoundary" ] /* bash */ ''
    set -euo pipefail
    umask 077
    dir="$(dirname "${cfg}")"
    mkdir -p "$dir"

    if [ ! -e "${cfg}" ]; then
      echo '{}' > "${cfg}"
    fi

    if ! ${jq} -e . "${cfg}" > /dev/null 2>&1; then
      cp -f "${cfg}" "${cfg}.bak.$(date +%s)" || true
      echo '{}' > "${cfg}"
    fi

    tmp="$(mktemp "$dir/.${name}.json.XXXXXX")"
    trap 'rm -f "$tmp"' EXIT
    ${jq} -s '${mergeExpr}' "${cfg}" ${managedFile} > "$tmp"
    chmod ${mode} "$tmp"
    mv -f "$tmp" "${cfg}"
    trap - EXIT
  '';
}
