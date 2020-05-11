## Persistent Data: Bind Mounting

## Mount a host path to a container path 

We will be modifying the index.html by overwriting it

Use the index.html from this path and mount it in the container path "/usr/share/nginx/html"

docker container run -d --name nginx -p 80:80 -v $(pwd):/usr/share/nginx/html nginx


Trigger another container from the same image without mounts ...

docker container run -d --name nginx2 -p 8080:80 nginx


docker container exec -it nginx bash

