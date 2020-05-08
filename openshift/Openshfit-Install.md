# Deploying OpenShift 3.9  Cluster

### Infrastructure Setup:

Create Virtual VM using with following [Virtual Server](../Infrastructure-Setup/README.md)  Link and Below Deatils.  

| Host Name               | IP Address   | CPU  | RAM   | HDD  | OS        | Role        |
| ----------------------- | ------------ | ---- | ----- | ---- | --------- | ----------- |
| master.lab.example.com  | 192.168.1.11 | 4    | 10240 | 100  | Centos7.X | Master Node |
| worker1.lab.example.com | 192.168.1.12 | 4    | 10240 | 100  | Centos7.X | Worker Node |
| worker2.lab.example.com | 192.168.1.13 | 4    | 10240 | 100  | Centos7.x | Worker Node |
| infra1.lab.example.com  | 192.168.1.14 | 4    | 10240 | 100  | Centos7.x | Infra1 Node |

### Preparing Nodes:

##### Step 1: Set the hostname with respective nodes:

```shell
# hostnamectl set-hostname master.lab.example.com   # In Master Node
# hostnamectl set-hostname worker1.lab.example.com  # In Worker1 Node
# hostnamectl set-hostname worker2.lab.example.com  # In Worker2 Node
# hostnamectl set-hostname infra1.lab.example.com   # In Infra1 Node
```

##### Step 2: DNS Server Setup in Workstation Node:

Create Local DNS Server on Workstation using with [DNS Setup](Local-DNS-Setup.md)

##### Step 3: Use the below command to update the System on all nodes: 

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

##### Step 4: Once the systems came back UP/ONLINE, Install the following Packages on all nodes:  

```shell
# yum install -y wget git vim nano net-tools docker-1.13.1 bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct openssl-devel httpd-tools NetworkManager python-cryptography python-devel python-passlib java-1.8.0-openjdk-headless "@Development Tools"
```

##### Step 5: Configure Ansible Repository and Install on master Node only. 

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

##### Step 6:  Start and Enable NetworkManager and Docker Services on all nodes:

```shell
# systemctl start NetworkManager && systemctl enable NetworkManager && systemctl status NetworkManager
```

```shell
# systemctl start docker && systemctl enable docker && systemctl status docker
```

##### Step 8: Generate SSH Keys on Master Node and install it on all nodes:

```shell
# ssh-keygen -f ~/.ssh/id_rsa -N ''
# for host in master.lab.example.com worker1.lab.example.com worker2.lab.example.com infra1.lab.example.com ; do ssh-copy-id -i ~/.ssh/id_rsa.pub $host; done
```

### Install Openshift

##### Step 1: Clone Openshift-Ansible Git Repo on Master Machine:

```shell
# git clone https://github.com/openshift/openshift-ansible.git
# cd openshift-ansible && git fetch && git checkout release-3.9
```

##### Step 2: Now Create Your Own Inventory file for Ansible as following on master Node: 

```shell
# vim ~/inventory.ini
```

```
[OSEv3:children]
masters
nodes
etcd
nfs

[masters]
master.lab.example.com openshift_ip=192.168.1.11

[etcd]
master.lab.example.com openshift_ip=192.168.1.11

[nfs]
master.lab.example.com openshift_ip=192.168.1.11

[nodes]
master.lab.example.com openshift_ip=192.168.1.11 openshift_schedulable=true
worker1.lab.example.com openshift_ip=192.168.1.12 openshift_schedulable=true openshift_node_labels="{'region': 'primary', 'zone': 'default'}"
worker2.lab.example.com openshift_ip=192.168.1.13 openshift_schedulable=true openshift_node_labels="{'region': 'primary', 'zone': 'default'}"
infra1.lab.example.com openshift_ip=192.168.1.14 openshift_schedulable=true openshift_node_labels="{'region': 'infra', 'zone': 'default'}"

[OSEv3:vars]
debug_level=4
ansible_ssh_user=root
openshift_enable_service_catalog=true
ansible_service_broker_install=true

containerized=false
os_sdn_network_plugin_name='redhat/openshift-ovs-multitenant'
openshift_disable_check=disk_availability,docker_storage,memory_availability,docker_image_availability

openshift_node_kubelet_args={'pods-per-core': ['10']}

deployment_type=origin
openshift_deployment_type=origin

openshift_release=v3.9.0
openshift_pkg_version=-3.9.0
openshift_image_tag=v3.9.0
openshift_service_catalog_image_version=v3.9.0
template_service_broker_image_version=v3.9.0
osm_use_cockpit=true


# Login Details paswword Configuration
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]
openshift_master_htpasswd_file='/etc/origin/master/htpasswd'

# put the router on dedicated infra1 node
openshift_hosted_router_selector='region=infra'
openshift_master_default_subdomain=apps.lab.example.com
openshift_public_hostname=master.lab.example.com
openshift_master_api_port=8443
openshift_master_console_port=8443

# put the image registry on dedicated infra1 node
openshift_hosted_registry_selector='region=infra'

# NFS Configuration for Registry
openshift_hosted_registry_storage_kind=nfs
openshift_hosted_registry_storage_access_modes=['ReadWriteMany']
openshift_hosted_registry_storage_nfs_directory=/exports
openshift_hosted_registry_storage_nfs_options='*(rw,root_squash)'
openshift_hosted_registry_storage_volume_name=registry
openshift_hosted_registry_storage_volume_size=10Gi
```

##### Step 3: Use the below ansible playbook command to check the prerequisites to deploy OpenShift Cluster on master Node: 

```shell
# mkdir -p /etc/origin/master/
# touch /etc/origin/master/htpasswd
# ansible-playbook -i ~/inventory.ini playbooks/prerequisites.yml
```





##### Step 4: Once prerequisites completed without any error use the below ansible playbook to Deploy OpenShift Cluster on master Node: 

```shell
# ansible-playbook -i ~/inventory.ini playbooks/deploy_cluster.yml
```

Now you have to wait approx 20-30 Minutes to complete the Installation





##### Step 5: Once the Installation is completed, Create a admin user in OpenShift with Password "Redhat@123" from master Node: 

Install httpd-tools on master

```shell
# htpasswd -b /etc/origin/master/htpasswd admin Redhat@123
# ls -l /etc/origin/master/htpasswd
# cat /etc/origin/master/htpasswd
```

Use the below command to assign cluster-admin Role to admin user:

```shell
# oc adm policy add-cluster-role-to-user cluster-admin admin
```

##### Step 6: Use the below command to login as admin user on CLI

```bash
# oc login
```

```
Authentication required for https://master.lab.example.com:8443 (openshift)
Username: admin
Password: Redhat@123
Login successful.
```

```shell
# oc whoami
```

Login GUI  with https://master.lab.example.com:8443