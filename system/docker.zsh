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

