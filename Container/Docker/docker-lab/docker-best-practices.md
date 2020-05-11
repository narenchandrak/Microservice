# Docker best practices 

## Please have in mind when working with docker containers and building images

1. Create Dockerfiles with cache (of the layers) in mind.
2. Use empty lines, comments and backslashes ("") for readability.
3. Think of creating your own private registry.
4. Use docker-compose.yml templates if you need permanent containers.
5. Group common operations under the same instruction.
6. Dont install useless software.
7. Keep images small and unique.
8. Search for similar public images before creating your own.
9. When you need software to install another software remove the first after the build.
10. Use ADD and VOLUME at the end of the Dockerfile (except if files are needed before).
11. Prefer using an ENTRYPOINT always.
12. Install specific versions of software.
13. With COPY the directories are not copied, only their files.
14. When using a base image choose a specific tag (avoid default tag "latest").
15. Prefer the tiny base images (busybox, alpine, tinycore, baseimage etc).
16. Build your own base image when you want full control of the Dockerfile.
17. Things that do not change often should stay on top of the Dockerfile (eg MAINTAINER).
18. If you need to work with local files use VOLUME and not ADD.
19. Test builds locally before triggering automated builds on online docker registries.
20. Be careful with volumes. When docker mounts folders on read-write mode your files may be deleted.
21. A volume will never be deleted as long as a container is linked to it.
22. Use shell scripts for complicated RUN commands on the Dockerfile as also as for starting processes on containers.
23. Prefer running processes inside containers with a non ROOT user for security reasons.

