# Configuring the Persistence Storage for Registry

##### Step 1: Get the Project List and set default project 'default'

```shell
oc get projects
oc project default
```

![](C:\Users\Naren Chandra\OneDrive\Naren_Chandra_R&D\microservices\GitHub\Microservice\openshift\PV-Registry\1.jpg)

##### step 2: Get the list of Pods

```shell
oc get pods
```

<img src="C:\Users\Naren Chandra\OneDrive\Naren_Chandra_R&amp;D\microservices\GitHub\Microservice\openshift\PV-Registry\2.jpg" style="zoom:150%;" />

##### Step 3: verify the registry Pod have persistent volume or not

```shell
oc describe pod docker-registry-1-zrt9t | grep -A 2 'Volumes'
oc set volume pod docker-registry-1-zrt9t
```

![](C:\Users\Naren Chandra\OneDrive\Naren_Chandra_R&D\microservices\GitHub\Microservice\openshift\PV-Registry\3.jpg)

### Configure NFS Server to share persistent Storage for registry Pod

##### Step 1: Install NFS Packages on Server Node:

```shell
yum install nfs-utils -y
```

##### Step 2: Configure NFS Service

```shell
mkdir -p /exports/registry
chmod o+rwx /exports/registry/
echo "/exports/registry   *(rw,sync)" >> /etc/exports
```

##### Step 3: Start & Verify NFS Service Configuration on Server Node

```shell
cat /etc/exports
systemctl start nfs-server
systemctl enable nfs-server
showmount -e
```

Enable firewall for NFS service on Server Node

```shell
firewall-cmd --permanent --add-service=nfs
firewall-cmd --permanent --add-service=mountd
firewall-cmd --permanent --add-service=rpc-bind
firewall-cmd --reload
```

##### Step 4: Now go to Master node and Get NFS Share and Deployment Config details 

```shell
### Add CNAME for NFS with respective server.lab.example.com in /etc/hosts on all nodes ###
vim /etc/hosts
192.168.122.x server.lab.example.com server
192.168.122.x nfs.lab.example.com nfs
```

![](C:\Users\Naren Chandra\OneDrive\Naren_Chandra_R&D\microservices\GitHub\Microservice\openshift\PV-Registry\4.jpg)

```
showmount -e nfs.lab.example.com
oc get dc
```

<img src="C:\Users\Naren Chandra\OneDrive\Naren_Chandra_R&amp;D\microservices\GitHub\Microservice\openshift\PV-Registry\5.jpg" style="zoom:150%;" />

##### Step 5: Create a YAML file to configure persistent volume on master node

```shell
vim registry-volume.yaml
```

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: registry-volume
spec:
  capacity:
    storage: 5Gi
  accessModes:
  - ReadWriteMany
  nfs:
    path: /exports/registry/
    server: nfs.lab.example.com
  persistentVolumeReclaimPolicy: Recycle
  claimRef:
    name: registry-pvclaim
    namespace: default
```

```shell
oc create -f registry-volume.yaml
oc get pv
```

![](C:\Users\Naren Chandra\OneDrive\Naren_Chandra_R&D\microservices\GitHub\Microservice\openshift\PV-Registry\6.jpg)

##### Step 6: Claim the persistent volume for registry Pod

```shell
oc get pods
oc get dc

oc set volume dc/docker-registry -n default --add --overwrite --name=registry-storage -t pvc --claim-name=registry-pvclaim --claim-size=5Gi --claim-mode='ReadWritemany'

oc get pvc
oc get pv
oc get pods
```

![](C:\Users\Naren Chandra\OneDrive\Naren_Chandra_R&D\microservices\GitHub\Microservice\openshift\PV-Registry\7.jpg)

```shell
oc get dc
oc describe pod docker-registry-2-4rt86 | grep -A 8 'Volumes'
```

![](C:\Users\Naren Chandra\OneDrive\Naren_Chandra_R&D\microservices\GitHub\Microservice\openshift\PV-Registry\8.jpg)

##### Step 7: Verify that the registry is using the NFS share to save container images.

Create a new project named registry-storage:

- Now Open Web Browser from Workstation using X11 display and point to the following URL to access OpenShift Dashboard:  
- Login to OpenShift Dashboard : https://master.lab.example.com:8443/ 

```
Username : admin 
Password : Redhat@123
```

- Click on "+ Create Project"  

```
Name: registry-storage-lab 
Display Name: registry storage lab 
Description: registry storage lab
```

- Now Select "**registry storage lab**" --> Brows Catalog --> PHP --> Next ->  Click on **Try Sample Repository** 

```
Version: 7.0 - latest 
Application Name: cakephp-ex 
Git Repositories: https://github.com/openshift/cakephp-ex.git  
```

- Create -> Close. 

- Now click on Overview and expend rgtest App for more details.  
- You have to wait till build successfully completed. Once completed, you will have a running pod from it.  
- Now go back to CLI Console on master node, and do the following to verify the pod. 

Login to Master Node

```shell
oc get pods -n registry-storage-lab -o wide
```

![](C:\Users\Naren Chandra\OneDrive\Naren_Chandra_R&D\microservices\GitHub\Microservice\openshift\PV-Registry\9.jpg)

Now go back to NFS Server and check the share for registry Images 

```shell
ls -h /exports/registry/
ls -l /exports/registry/
```

![](C:\Users\Naren Chandra\OneDrive\Naren_Chandra_R&D\microservices\GitHub\Microservice\openshift\PV-Registry\10.jpg)