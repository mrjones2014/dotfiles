function mk --wraps make
    if test (count $argv) -lt 1
        set -l cmd (popup.bash 'make -rpn | sed -n -e \'/^$/ { n ; /^[^ .#][^ ][^/]*:/ { s/:.*$// ; p ; } ; }\' | sort -u | fzf')
        if test -z "$cmd"
            return
        end

        make "$cmd"
    end

    make $argv
end
