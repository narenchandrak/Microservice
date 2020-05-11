# Kubernetes Object

Here’s an example .yaml file that shows the required fields and object spec for a Kubernetes Deployment:

    kubectl create -f ./deployment.yaml --record
    
The output is similar to this:

    deployment.apps/nginx-deployment created
    
## Required Fields

In the .yaml file for the Kubernetes object you want to create, you’ll need to set values for the following fields:


    1. apiVersion - Which version of the Kubernetes API you’re using to create this object
    2. kind - What kind of object you want to create
    3. metadata - Data that helps uniquely identify the object, including a name string, UID, and optional namespace

The Kubernetes API Reference can help you find the spec format for all of the objects you can create using Kubernetes

References:
    
   [Workshop Setup](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#-strong-api-overview-strong-)
    
