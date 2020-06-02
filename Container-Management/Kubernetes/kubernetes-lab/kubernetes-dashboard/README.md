# Kubernetes Dashboard Installation

Kubernetes Dashboard is a general purpose, web-based UI for Kubernetes clusters. It allows users to manage applications running in the cluster and troubleshoot them, as well as manage the cluster itself.

Installation:

Step 1 - Create certificate

openssl can manually generate certificates for your cluster.

1. Generate a dashboard.key with 2048bit:
    ```
    mkdir ~/certs
    cd ~/certs/
    openssl genrsa -out dashboard.key 2048
    ```
    
2. Generate a dashboard.crt using dashboard.key:
    ```
    openssl req -x509 -new -nodes -key dashboard.key -subj "/CN=<MASTER_IP>" -days 10000 -out dashboard.crt
    ```
    
3. Generate a server.key with 2048bit:
    ```
    openssl genrsa -out server.key 2048
    ```
    
4. Create a config file for generating a Certificate Signing Request (CSR). Be sure to substitute the values marked with angle brackets (e.g. <MASTER_IP>) with real values before saving this to a file (e.g. csr.conf). Note that the value for MASTER_CLUSTER_IP is the service cluster IP for the API server as described in previous subsection.
    ```
    wget https://raw.githubusercontent.com/narenchandrak/Microservice/master/Container-Management/Kubernetes/kubernetes-lab/kubernetes-dashboard/csr.conf
    ```
    
    Sample Output:
    
    ```
    [ req ]
    default_bits = 2048
    prompt = no
    default_md = sha256
    req_extensions = req_ext
    distinguished_name = dn
    
    [ dn ]
    C = IN
    ST = Tamil Nadu
    L = Chennai
    O = Example
    OU = Example
    CN = 192.168.122.134
    
    [ req_ext ]
    subjectAltName = @alt_names
    
    [ alt_names ]
    DNS.1 = kubernetes
    DNS.2 = kubernetes.default
    DNS.3 = kubernetes.default.svc
    DNS.4 = kubernetes.default.svc.cluster
    DNS.5 = kubernetes.default.svc.cluster.local
    IP.1 = 192.168.122.134
    IP.2 = 10.96.0.1
    
    [ v3_ext ]
    authorityKeyIdentifier=keyid,issuer:always
    basicConstraints=CA:FALSE
    keyUsage=keyEncipherment,dataEncipherment
    extendedKeyUsage=serverAuth,clientAuth
    subjectAltName=@alt_names
    ```
    
    
    
5. Generate the certificate signing request based on the config file:
    ```
    openssl req -new -key server.key -out dashboard.csr -config csr.conf
    ```

6. Generate the server certificate using the dashboard.key, dashboard.crt and dashboard.csr:
    ```
    openssl x509 -req -in dashboard.csr -CA dashboard.crt -CAkey dashboard.key -CAcreateserial -out dashboard.crt -days 10000 -extensions v3_ext -extfile csr.conf
    ```

7. View the certificate:
    ```
    openssl x509  -noout -text -in ./dashboard.crt
    ```

Step 2 - Import CA:

Custom certificates have to be stored in a secret named kubernetes-dashboard-certs in kube-system namespace. Assuming that you have dashboard.crt and dashboard.key files stored under $HOME/certs directory, you should create secret with contents of these files:

    kubectl create secret generic kubernetes-dashboard-certs --from-file=$HOME/certs -n kubernetes-dashboard

Step 3 - Deploy Dashboard:

    kubectl create --edit -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.1/aio/deploy/recommended.yaml

Under Deployment section, add arguments to pod definition, it should look as follows:

```
      containers:
      - args:
        - --tls-cert-file=/tls.crt
        - --tls-key-file=/tls.key
```

Creating a ClusterRoleBinding and Service Account

```
kubectl apply -f https://raw.githubusercontent.com/narenchandrak/Microservice/master/Container-Management/Kubernetes/kubernetes-lab/kubernetes-dashboard/dashboard-admin.yaml
```

Step 4 - Modify kubernetes dashboard service:

    kubectl -n kubernetes-dashboard get service kubernetes-dashboard
    
    kubectl -n kubernetes-dashboard edit service kubernetes-dashboard
    
    Note: Change value for spec.type from "ClusterIP" to "NodePort" . Then save the file (:wq)

Step 5 - Check port on which Dashboard was exposed:

    kubectl -n kubernetes-dashboard get service kubernetes-dashboard

Step 6 - Get Service Account Token and Login

    kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')


Update:

Once installed, the deployment is not automatically updated. In order to update it you need to delete the deployment's pods and wait for it to be recreated. After recreation, it should use the latest image.

Delete all Dashboard pods (assuming that Dashboard is deployed in kube-system namespace):

    kubectl -n kubernetes-dashboard delete $(kubectl -n kubernetes-dashboard get pod -o name | grep dashboard)
