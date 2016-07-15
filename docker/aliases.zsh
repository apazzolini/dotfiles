alias dm='docker-machine'

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

ecstail() {
    if [ -z "$2" ]
    then
        taillen=1000
    else
        taillen=$2
    fi

    short=`ssh ecs docker ps | grep $1 | awk '{print $1}'`
    long=`ssh ecs docker inspect --format '{{.Id}}' $short`

    ssh ecs sudo tail -fn $taillen "/var/lib/docker/containers/$long/$long-json.log" | jq '.log|fromjson' -c --unbuffered | bunyan -o short $3
}

ecsdl() {
    short=`ssh ecs docker ps | grep $1 | awk '{print $1}'`
    long=`ssh ecs docker inspect --format '{{.Id}}' $short`
    ssh ecs sudo cp "/var/lib/docker/containers/$long/$long-json.log" /home/ec2-user
    ssh ecs sudo gzip "/home/ec2-user/$long-json.log"
    ssh ecs sudo chown ec2-user "/home/ec2-user/$long-json.log.gz"
    scp ecs:/home/ec2-user/$long-json.log.gz .
    ssh ecs rm "/home/ec2-user/$long-json.log.gz"
}
