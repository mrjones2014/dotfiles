function nuke-docker
    set -l docker_container_names (docker ps --format "{{.Names}}")
    if test -n "$docker_container_names"
        docker kill $docker_container_names
    else
        echo "No docker containers running."
    end
end

function nuke-from-orbit
    nuke-docker
    killall node
    killall hugo
end
