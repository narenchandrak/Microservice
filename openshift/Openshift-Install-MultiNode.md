# Deploying OpenShift 3.9  Cluster

### Infrastructure Setup:

Create Virtual VM using with following [Virtual Server](../Infrastructure-Setup/README.md)  Link and Below Details.  

| Host Name               | CPU  | RAM   | Disk-1 | Disk-2 | OS        | Role        |
| ----------------------- | ---- | ----- | ------ | ------ | --------- | ----------- |
| master.lab.example.com  | 4    | 20480 | 50GB   | 20GB   | Centos7.X | Master Node |
| worker1.lab.example.com | 2    | 8192  | 50GB   | 20GB   | Centos7.X | Worker Node |
| worker2.lab.example.com | 2    | 8192  | 50GB   | 20GB   | Centos7.x | Worker Node |
| infra1.lab.example.com  | 2    | 8192  | 50GB   | 20GB   | Centos7.x | Infra Nod   |
| server.lab.example.com  | 2    | 2048  | 100GB  |        | Centos7.x | DNS & NFS   |

```shell
sh ~/Microservice/Infrastructure-Setup/Create-Virtual-VM.sh -o create -n master -d lab.example.com -c 4 -r 20480 -v 2 -a 50 -b 20
sh ~/Microservice/Infrastructure-Setup/Create-Virtual-VM.sh -o create -n worker1 -d lab.example.com -c 2 -r 8192 -v 2 -a 50 -b 20
sh ~/Microservice/Infrastructure-Setup/Create-Virtual-VM.sh -o create -n worker2 -d lab.example.com -c 2 -r 8192 -v 2 -a 50 -b 20
sh ~/Microservice/Infrastructure-Setup/Create-Virtual-VM.sh -o create -n infra1 -d lab.example.com -c 2 -r 8192 -v 2 -a 50 -b 20
sh ~/Microservice/Infrastructure-Setup/Create-Virtual-VM.sh -o create -n server -d lab.example.com -c 2 -r 2048 -v 1 -a 100



### Add CNAME for NFS with respective server.lab.example.com in /etc/hosts on workstation ###
vim /etc/hosts
192.168.122.x server.lab.example.com server
192.168.122.x nfs.lab.example.com nfs

### Copy /etc/hosts file all the nodes ###

scp /etc/hosts master:/etc/hosts
scp /etc/hosts worker1:/etc/hosts
scp /etc/hosts worker2:/etc/hosts
scp /etc/hosts infra1:/etc/hosts
scp /etc/hosts server:/etc/hosts
```

##### DNS Server Setup on Server Node

Create DNS Service on Server Node using with [DNS Setup](DNS-Setup.md)

**References:**

1. https://docs.okd.io/3.9/install_config/install/planning.html
2. https://docs.okd.io/3.9/install_config/install/prerequisites.html

### Preparing Nodes:

##### Step 1: Use the below command to update the System on all nodes

```shell
yum update -y
```

Use the below command to compare the kernel on all nodes: 

```shell
echo "Latest Installed Kernel : $(rpm -q kernel --last | head -n 1 | awk '{print $1}')" ; echo "Current Running Kernel  : kernel-$(uname -r)"
```

If you have different kernel in above command output, then you need to reboot all the system. otherwise jump to Step 2.

```shell
reboot
```

##### Step 2: Once the systems came back UP/ONLINE, Install the following Packages on all nodes(Excluding Server Node)

```shell
yum install -y wget git vim nano nfs-utils net-tools docker-1.13.1 bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct openssl-devel httpd-tools NetworkManager python-cryptography python-devel python-passlib java-1.8.0-openjdk-headless "@Development Tools"
```

##### Step 3: Configure Ansible Repository and Install on master Node only. 

```shell
curl -o ansible.rpm https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.6.5-1.el7.ans.noarch.rpm

yum -y install ansible.rpm pyOpenSSL
```

##### Step 6: Configuring Docker Storage on all nodes

```shell
cat <<EOF > /etc/sysconfig/docker-storage-setup 
DEVS=/dev/vdb 
VG=docker-vg 
EOF

docker-storage-setup
lsblk
```

Reference: 

1. https://docs.okd.io/3.9/install_config/install/host_preparation.html#configuring-docker-storage

##### Step 7:  Start and Enable NetworkManager and Docker Services on all nodes

```shell
systemctl start NetworkManager && systemctl enable NetworkManager && systemctl status NetworkManager
```

```shell
systemctl start docker && systemctl enable docker && systemctl status docker
```

##### Step 8: Generate SSH Keys on Master Node and install it on all nodes

```shell
ssh-keygen -f ~/.ssh/id_rsa -N ''

for host in master.lab.example.com worker1.lab.example.com worker2.lab.example.com infra1.lab.example.com ; do ssh-copy-id -i ~/.ssh/id_rsa.pub $host; done
```

##### Step 9: registry-console Fix on all the nodes

```shell
wget http://mirror.centos.org/centos/7/os/x86_64/Packages/python-rhsm-certificates-1.19.10-1.el7_4.x86_64.rpm

rpm2cpio python-rhsm-certificates-1.19.10-1.el7_4.x86_64.rpm | cpio -iv --to-stdout ./etc/rhsm/ca/redhat-uep.pem | tee /etc/rhsm/ca/redhat-uep.pem
```

References:

1. https://github.com/openshift/openshift-ansible/issues/12115
2. https://github.com/cockpit-project/cockpit/issues/13654
3. https://bugs.centos.org/view.php?id=14785

### Install Openshift

##### Step 1: Clone Openshift-Ansible Git Repo on Master Machine

```shell
git clone https://github.com/openshift/openshift-ansible.git

cd openshift-ansible && git fetch && git checkout release-3.9
```

##### Step 2: Select the Installation method

|                    Training                    |                     Production                     |
| :--------------------------------------------: | :------------------------------------------------: |
| [Openshift Training](Training-Installation.md) | [Openshift Production](Production-Installation.md) |

References:

1. https://docs.openshift.com/container-platform/3.9/install_config/install/advanced_install.html