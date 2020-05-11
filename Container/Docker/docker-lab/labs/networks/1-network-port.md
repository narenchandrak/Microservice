## Docker Networks: Concepts for Private and Public Comms in Containers

docker container run -p 80:80 --name webhost -d nginx

docker container port webhost

docker container inspect <id>

## To filter only the IP address
docker container inspect --format '{{ .NetworkSettings.IPAddress }}' webhost

## We can also use the grep utility to filter searches

docker container inspect <id> | grep IPAdress
