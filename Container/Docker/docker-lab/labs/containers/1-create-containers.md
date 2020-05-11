# Creating and Using Containers

## Check docker --help for command usages

docker version

docker info

docker

docker container run

docker run

# Our First Container 
## Starting a Nginx Web Server

docker container run --publish 80:80 nginx

docker container run --publish 80:80 --detach nginx

docker container ls

docker container stop <container-id>

docker container ls

docker container ls -a

docker container run --publish 80:80 --detach --name webhost nginx

docker container ls -a

docker container logs webhost

docker container top

docker container top webhost

docker container --help

docker container ls -a

docker container rm <container-id> <container-id> <container-id>

docker container ls
