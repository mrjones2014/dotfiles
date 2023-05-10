function check-architecture --description "Check if the shell is running natively on ARM, natively on x86, or through Rosetta 2"
    if [ (uname -m) = x86_64 ]
        if [ "(sysctl -in sysctl.proc_translated)" = 1 ]
            echo "Running on Rosetta 2"
            set -gx ARCHPREFERENCE arm64
        else
            echo "Running on native Intel"
        end
    else if [ (uname -m) = arm64 ]
        echo "Running on ARM"
    else
        echo "Unknown architecture: $arch_name"
    end
end
