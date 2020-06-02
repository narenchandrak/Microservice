# Kubernetes

In this workshop you will learn how to:

* Provision a basic Kubernetes cluster from the ground up using Ansible
* Deploy and manage Docker containers using kubectl

Kubernetes Version: v1.18.3

There are also [slides]().

## Labs

Kubernetes is all about applications and in this section you will utilize the Kubernetes API to deploy, manage, and upgrade applications. In this part of the workshop you will use an example application called "app" to complete the labs.

* [Kubernetes Cluster](kubernetes-cluster/README.md)
* [Kubernetes Object](kubernetes-lab/kubernetes/labs/Kubernetes-Object.md)
* [Kubernetes Namespaces](kubernetes-lab/kubernetes/labs/Kubernetes-Namespaces.md)
* [Kubernetes Dashboard](kubernetes-lab/kubernetes-dashboard/README.md)
* [Containerizing your application](kubernetes-lab/kubernetes/labs/containerizing-your-application.md)
* [Creating and managing pods](kubernetes-lab/kubernetes/labs/creating-and-managing-pods.md)
* [Monitoring and health checks](kubernetes-lab/kubernetes/labs/monitoring-and-health-checks.md)
* [Managing application configurations and secrets](kubernetes-lab/kubernetes/labs/managing-application-configurations-and-secrets.md)
* [Creating and managing services](kubernetes-lab/kubernetes/labs/creating-and-managing-services.md)
* [Creating and managing deployments](kubernetes-lab/kubernetes/labs/creating-and-managing-deployments.md)
* [Rolling out updates](kubernetes-lab/kubernetes/labs/rolling-out-updates.md)
* [Resource Quotas](kubernetes-lab/kubernetes/labs/Resource-Quotas.md)
* [Pod Security Policies](kubernetes-lab/kubernetes/labs/Pod-Security-Policies.md)
* [Helm install](kubernetes-lab/helm/helm-install/README.md)

## Lab Docker images

App is an example 12 Factor application. During this workshop you will be working with the following Docker images:

* [narenchandra/monolith](https://hub.docker.com/r/narenchandra/monolith) - Monolith includes auth and hello services.
* [narenchandra/auth](https://hub.docker.com/r/narenchandra/auth) - Auth microservice. Generates JWT tokens for authenticated users.
* [narenchandra/hello](https://hub.docker.com/r/narenchandra/hello) - Hello microservice. Greets authenticated users.
* [ngnix](https://hub.docker.com/_/nginx) - Frontend to the auth and hello services.
## Links

  * [Kubernetes](https://www.kubernetes.io)
  * [Docker](https://docs.docker.com)
  * [etcd](https://coreos.com/docs/distributed-configuration/getting-started-with-etcd)
  * [nginx](http://nginx.org)
