# Installation of Kubernetes-Cluster

### Infrastructure Setup:

Create Virtual VM using with following [Virtual Server](../../../Infrastructure-Setup/README.md)  Link and Below Details.  

| Host Name           | CPU  | RAM   | Disk-1 | Disk-2 | OS        | Role        |
| ------------------- | ---- | ----- | ------ | ------ | --------- | ----------- |
| master.example.com  | 4    | 20480 | 50GB   | 20GB   | Centos7.X | Master Node |
| worker1.example.com | 2    | 8192  | 50GB   | 20GB   | Centos7.X | Worker Node |
| worker2.example.com | 2    | 8192  | 50GB   | 20GB   | Centos7.x | Worker Node |
| server.example.com  | 2    | 2048  | 100GB  |        | Centos7.x | DNS & NFS   |

```shell
sh ~/Microservice/Infrastructure-Setup/Create-Virtual-VM.sh -o create -n master -d example.com -c 4 -r 20480 -v 2 -a 50 -b 20
sh ~/Microservice/Infrastructure-Setup/Create-Virtual-VM.sh -o create -n worker1 -d example.com -c 2 -r 8192 -v 2 -a 50 -b 20
sh ~/Microservice/Infrastructure-Setup/Create-Virtual-VM.sh -o create -n worker2 -d example.com -c 2 -r 8192 -v 2 -a 50 -b 20
sh ~/Microservice/Infrastructure-Setup/Create-Virtual-VM.sh -o create -n server -d example.com -c 2 -r 2048 -v 1 -a 100



### Add CNAME for NFS with respective server.lab.example.com in /etc/hosts on workstation ###
vim /etc/hosts
192.168.122.x server.example.com server
192.168.122.x nfs.example.com nfs

### Copy /etc/hosts file all the nodes ###

scp /etc/hosts master:/etc/hosts
scp /etc/hosts worker1:/etc/hosts
scp /etc/hosts worker2:/etc/hosts
scp /etc/hosts server:/etc/hosts
```

##### DNS Server Setup on Server Node

Create DNS Service on Server Node using with [DNS Setup](DNS-Setup.md)

##### Kubernetes Cluster Setup

Step 1 — Install Ansible on Workstation base node:

    yum install -y ansible

Step 2 — check password-less login to Kubernetes nodes

    cd ~/Microservice/Container-Management/Kubernetes/kubernetes-cluster
    
    ansible all -i hosts -m shell -a "date"
    
    Note: Enter yes continusly for ssh keys exchange

Step 3 — Install dependencies in all Kubernetes nodes

    ansible-playbook -i hosts kube-dependencies.yml --syntax-check
    
    ansible-playbook -i hosts kube-dependencies.yml

Step 4 — Instate Kubeadm in Kubernetes master node

    ansible-playbook -i hosts master.yml --syntax-check
    
    ansible-playbook -i hosts master.yml

Step 5 — Added slave nodes to master node

    ansible-playbook -i hosts slaves.yml --syntax-check
    
    ansible-playbook -i hosts slaves.yml

