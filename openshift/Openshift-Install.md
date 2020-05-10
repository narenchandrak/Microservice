Deploying OpenShift 3.9  Cluster

### Infrastructure Setup:

Create Virtual VM using with following [Virtual Server](../Infrastructure-Setup/README.md)  Link and Below Details.  

| Host Name               | CPU  | RAM   | Disk-1 | Disk-2 | OS        | Role        |
| ----------------------- | ---- | ----- | ------ | ------ | --------- | ----------- |
| master.lab.example.com  | 4    | 16384 | 50GB   | 20GB   | Centos7.X | Master Node |
| worker1.lab.example.com | 2    | 8192  | 50GB   | 20GB   | Centos7.X | Worker Node |
| worker2.lab.example.com | 2    | 8192  | 50GB   | 20GB   | Centos7.x | Worker Node |
| infra1.lab.example.com  | 2    | 8192  | 50GB   | 20GB   | Centos7.x | Infra Node  |
| server.lab.example.com  | 2    | 4096  | 50GB   | 20GB   | Centos7.x | NFS & DNS   |

References:

1. https://docs.okd.io/3.9/install_config/install/planning.html
2. https://docs.okd.io/3.9/install_config/install/prerequisites.html

### Preparing Nodes:

##### Step 1: Set the hostname with respective nodes

```shell
# hostnamectl set-hostname master.lab.example.com   # In Master Node
# hostnamectl set-hostname worker1.lab.example.com  # In Worker1 Node
# hostnamectl set-hostname worker2.lab.example.com  # In Worker2 Node
# hostnamectl set-hostname infra1.lab.example.com   # In Infra1 Node
# hostnamectl set-hostname server.lab.example.com   # In server Node( DNS & NFS)
```

##### Step 2: Use the below command to update the System on all nodes

```shell
# yum update -y
```

Use the below command to compare the kernel on all nodes: 

```shell
# echo "Latest Installed Kernel : $(rpm -q kernel --last | head -n 1 | awk '{print $1}')" ; echo "Current Running Kernel  : kernel-$(uname -r)"
```

If you have different kernel in above command output, then you need to reboot all the system. otherwise jump to Step 4.

```shell
# reboot
```

##### Step 3: Once the systems came back UP/ONLINE, Install the following Packages on all nodes(Excluding Server Node)

```shell
# yum install -y wget git vim nano nfs-utils net-tools docker-1.13.1 bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct openssl-devel httpd-tools NetworkManager python-cryptography python-devel python-passlib java-1.8.0-openjdk-headless "@Development Tools"
```

##### Step 4: Configure Ansible Repository and Install on master Node only. 

```shell
# vim /etc/yum.repos.d/ansible.repo
```

```
[ansible]
name = Ansible Repo
baseurl = https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/
enabled = 1
gpgcheck =  0
```

```shell
# yum -y install ansible-2.6* pyOpenSSL
```

##### Step 5: DNS Server Setup in Server Node

Create DNS Service on Server Node using with [DNS Setup](DNS-Setup.md)

##### Step 6: NFS Server Setup in Server Node

Create NFS Service on Server Node using with [NFS Setup](NFS-Setup.md)

##### Step 7: Configuring Docker Storage on all nodes(Excluding Server Node)

```shell
# sudo cat <<EOF > /etc/sysconfig/docker-storage-setup 
DEVS=/dev/vdb 
VG=docker-vg 
EOF

# docker-storage-setup
# lsblk
```

Reference: 

1. https://docs.okd.io/3.9/install_config/install/host_preparation.html#configuring-docker-storage

##### Step 8:  Start and Enable NetworkManager and Docker Services on all nodes(Excluding Server Node)

```shell
# systemctl start NetworkManager && systemctl enable NetworkManager && systemctl status NetworkManager
```

```shell
# systemctl start docker && systemctl enable docker && systemctl status docker
```

##### Step 9: Generate SSH Keys on Master Node and install it on all nodes

```shell
# ssh-keygen -f ~/.ssh/id_rsa -N ''
# for host in master.lab.example.com worker1.lab.example.com worker2.lab.example.com infra1.lab.example.com ; do ssh-copy-id -i ~/.ssh/id_rsa.pub $host; done
```

### Install Openshift

##### Step 1: Clone Openshift-Ansible Git Repo on Master Machine

```shell
# git clone https://github.com/openshift/openshift-ansible.git
# cd openshift-ansible && git fetch && git checkout release-3.9
```

##### Step 2: Select the Installation method

|                    Training                    |                     Production                     |
| :--------------------------------------------: | :------------------------------------------------: |
| [Openshift Training](Training-Installation.md) | [Openshift Production](Production-Installation.md) |