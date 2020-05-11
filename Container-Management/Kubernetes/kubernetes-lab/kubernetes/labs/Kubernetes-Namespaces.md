# Kubernetes Namespaces

1. list the current namespaces in a cluster

        kubectl get namespaces
        
   Kubernetes starts with three initial namespaces:
   
        a. default: The default namespace for objects with no other namespace
        b. kube-system: The namespace for objects created by the Kubernetes system
        c. kube-public: This namespace is created automatically and is readable by all users (including those not authenticated).

2. get the summary of a specific namespace

        kubectl get namespaces <name>

3. Creating a new namespace

        kubectl create -f ./my-namespace.yaml
        
4. Deleting a namespace

        kubectl delete namespaces <insert-some-namespace-name>

5. Setting the namespace

        kubectl --namespace=<insert-namespace-name-here> run nginx --image=nginx
        
        kubectl --namespace=<insert-namespace-name-here> get pods 
        
        