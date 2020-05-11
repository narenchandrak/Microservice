# Accessing shell of a container:-

## Getting a Shell Inside Containers: No Need for SSH

docker container run -help

docker container run -it --name proxy nginx bash

docker container ls

docker container ls -a

docker container run -it --name ubuntu ubuntu

docker container ls

docker container ls -a

## Attaching shell to existing containers

docker container start --help

docker container start -ai ubuntu

docker container exec --help

docker container exec -it mysql bash

docker container ls


## Different images use different shells

docker pull alpine

docker image ls

docker container run -it alpine bash

docker container run -it alpine sh
