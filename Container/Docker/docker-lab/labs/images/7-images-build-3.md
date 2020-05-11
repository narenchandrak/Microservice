# Build a Ngingx server image on ubuntu
## Exposing a nginx from a ubuntu base 

##Dockerfile contents
### vim Dockerfile
FROM ubuntu
MAINTAINER Karthik S (karthik@docker.com)
RUN apt-get update
RUN apt-get install -y nginx
ENTRYPOINT [“/usr/sbin/nginx”, ”-g”]
EXPOSE 80


## Build the image using 

docker build -t ubunginx:1.0 .


## run a container out of the image and expose in a host port 8008

docker run -d -p 8008:80 --name webserver ubunginx:1.0
