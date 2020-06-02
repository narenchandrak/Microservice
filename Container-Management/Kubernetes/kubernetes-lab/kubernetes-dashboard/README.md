# Kubernetes Dashboard Installation

Kubernetes Dashboard is a general purpose, web-based UI for Kubernetes clusters. It allows users to manage applications running in the cluster and troubleshoot them, as well as manage the cluster itself.

Installation:

Step 1 - Deploy Dashboard:

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.1/aio/deploy/recommended.yaml
```

Creating a ClusterRoleBinding and Service Account

```
kubectl apply -f https://raw.githubusercontent.com/narenchandrak/Microservice/master/Container-Management/Kubernetes/kubernetes-lab/kubernetes-dashboard/dashboard-admin.yaml
```

Step 2 - Modify kubernetes dashboard service:

    kubectl -n kubernetes-dashboard get service kubernetes-dashboard
    
    kubectl -n kubernetes-dashboard edit service kubernetes-dashboard
    
    Note: Change value for spec.type from "ClusterIP" to "NodePort" . Then save the file (:wq)

Step 3 - Check port on which Dashboard was exposed:

    kubectl -n kubernetes-dashboard get service kubernetes-dashboard

Step 4 - Get Service Account Token and Login

    kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')


Update:

Once installed, the deployment is not automatically updated. In order to update it you need to delete the deployment's pods and wait for it to be recreated. After recreation, it should use the latest image.

Delete all Dashboard pods (assuming that Dashboard is deployed in kube-system namespace):

    kubectl -n kubernetes-dashboard delete $(kubectl -n kubernetes-dashboard get pod -o name | grep dashboard)
