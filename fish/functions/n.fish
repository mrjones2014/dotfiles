complete --no-files --command n --arguments "(_getNCompletions (commandline -cp))"

function _getNCompletions
    set -l args (string split " " $argv[1])
    set -l delegated_cmd $args[3..-1]
    complete --do-complete "$delegated_cmd"
end

function n --description "Run the provided command n times, e.g: n 5 cargo test"
    set -l count $argv[1]
    set -l cmd $argv[2..-1]
    for i in (seq $count)
        $cmd
    end
end
