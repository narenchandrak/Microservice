# Local registry on a container

docker run -d -p 5000:5000 --name registry registry

##Tag the images using

docker tag <<image-id>> <<registry-name>>/<<image-name>>
docker tag 7042885a156a localhost:5000/localnginx

