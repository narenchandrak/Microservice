# Virtual Infrastructure Setup

##### Step 1: KVM and QEMU installation

```shell
# yum install -y qemu-kvm qemu-img virt-manager libvirt libvirt-python libvirt-client virt-install virt-viewer bridge-utils
# systemctl start libvirtd
# systemctl enable libvirtd
```

##### Step 2: libvirt packages install

```shell
# yum install -y libvirt-client virt-install genisoimage git
```

##### Step 3: clone the git repository

```shell
# git clone https://github.com/narenchandrak/Microservice.git ~/Microservice/
```

##### Step 6: Generate RSA Key and copy to script.

```shell
# ssh-keygen -f ~/.ssh/id_rsa -N ''
# cat /root/.ssh/id_rsa.pub
# vim ~/Microservice/Infrastructure-Setup/Create-Virtual-VM.sh
```

Note: Replace with above RSA Key

##### Step 8: Create Instances

Example:

```shell
# sh ~/Microservice/Infrastructure-Setup/Create-Virtual-VM.sh -o create -n master -d example.com -c 2 -r 2048 -v 100G
```

### Create New Disk

Example:

```shell
# sh ~/Microservice/Infrastructure-Setup/Create-New-Disk.sh master vdb 20G
```
