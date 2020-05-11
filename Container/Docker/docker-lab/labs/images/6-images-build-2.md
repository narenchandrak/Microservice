## Building Images: The Dockerfile Basics

## Dockerfile contents
### vim Dockerfile
FROM busybox
MAINTAINER Karthik S (karthik@docker.com)
ENTRYPOINT ["/bin/cat"]
CMD ["/etc/passwd"]


Save the file and then build the image using 
docker build -t <name>:<tag> .

docker build -t mybusybox:1.0 .


##Run a container out oof our newly created image

docker run -it mybusybox:1.0
