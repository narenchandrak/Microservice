#Resource Quotas

1. Create a ResourceQuota
    
    ```
    kubectl create -f ./quota.yaml
    ```
    
    ```
    resourcequota/pods-high created
    resourcequota/pods-medium created
    resourcequota/pods-low created
    ```
2. View detailed information about the ResourceQuota
    ```
    kubectl describe quota
    ```
    
    ```
    Name:       pods-high
    Namespace:  default
    Resource    Used  Hard
    --------    ----  ----
    cpu         0     1k
    memory      0     200Gi
    pods        0     10
    
    
    Name:       pods-low
    Namespace:  default
    Resource    Used  Hard
    --------    ----  ----
    cpu         0     5
    memory      0     10Gi
    pods        0     10
    
    
    Name:       pods-medium
    Namespace:  default
    Resource    Used  Hard
    --------    ----  ----
    cpu         0     10
    memory      0     20Gi
    pods        0     10
    ```

# Configure Memory and CPU Quotas for a Namespace

1. Create a namespace
    ```
    kubectl create namespace quota-mem-cpu-example
    ```
2. Create a ResourceQuota
    ```
    kubectl create -f ./quota-mem-cpu.yaml --namespace=quota-mem-cpu-example
    ```
3. View detailed information about the ResourceQuota
    ```
    kubectl get resourcequota mem-cpu-demo --namespace=quota-mem-cpu-example --output=yaml
    ```
4. Create a Pod
    ```
    kubectl create -f ./quota-mem-cpu-pod.yaml --namespace=quota-mem-cpu-example
    ```
5. Verify that the Pod’s Container is running
    ```
    kubectl get pod quota-mem-cpu-demo --namespace=quota-mem-cpu-example
    ```
6. view detailed information about the ResourceQuota
    ```
    kubectl get resourcequota mem-cpu-demo --namespace=quota-mem-cpu-example --output=yaml
    ```
7. Attempt to create a second Pod
    ```
    kubectl create -f ./quota-mem-cpu-pod-2.yaml --namespace=quota-mem-cpu-example
    ```
The second Pod does not get created. The output shows that creating the second Pod would cause the memory request total to exceed the memory request quota.
    