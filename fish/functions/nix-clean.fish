function nix-clean
    nix-env --delete-generations old
    nix-store --gc
    nix-channel --update
    nix-env -u --always
    if test -f /etc/NIXOS
        for link in /nix/var/nix/gcroots/auto/*
            rm $(readlink "$link")
        end
    end
    nix-collect-garbage -d
end
