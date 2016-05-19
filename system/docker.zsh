d() { 
    # Lazily evaluate docker-machine env
    if [ -z "$DOCKER_HOST" ]; then
        eval $(docker-machine env); 
    fi

    docker $@;  
}

dssh() {
    d exec -t -i $1 bash -l
}

drmall() {
    d rm -f $(d ps -a -q)
    d rmi $(d images -q)
}

alias dm='docker-machine'

ecstail() {
    short=`ssh ecs docker ps | grep $1 | awk '{print $1}'`
    long=`ssh ecs docker inspect --format '{{.Id}}' $short`
    ssh ecs sudo tail -fn1000 "/var/lib/docker/containers/$long/$long-json.log" | jq '.log|fromjson' -c --unbuffered | bunyan -o short $2
}
