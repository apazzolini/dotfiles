dkill () {
    docker stop -t 0 $1
}

dbash () {
    docker exec -t -i $1 /bin/bash
}

dsh () {
    docker exec -t -i $1 /bin/sh
}
