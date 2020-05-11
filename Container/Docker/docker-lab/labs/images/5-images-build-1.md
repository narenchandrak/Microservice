# Docker build 

## We are gonna build on top of a alipne image

##Dockerfile contents

FROM alpine:latest
MAINTAINER Karthik S (karthik@docker.com)
RUN apk add vim
RUN apk add curl

## Build the images using 
docker build -t myalpine .

## run the container and test if vim is installed

docker run -it myalpine sh
