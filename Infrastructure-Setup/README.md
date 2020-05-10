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

##### Step 3: Create images directory

```shell
# git clone https://github.com/narenchandrak/Microservice.git ~/Microservice/
# mkdir -p ~/Microservice/images
```

##### Step 4: Download Image

```shell
# cd ~/Microservice/images
# wget http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2.xz
```

##### Step 5: Extract the Image

```shell
# xz --decompress CentOS-7-x86_64-GenericCloud.qcow2.xz
```

##### Step 6: Generate RSA Key and copy to script.

```shell
# ssh-keygen -f ~/.ssh/id_rsa -N ''
# cat /root/.ssh/id_rsa.pub
# vim ~/Microservice/Infrastructure-Setup/Create-Virtual-VM.sh
```

Note: Replace with above RSA Key

##### step 7: Change RAM , CPU, HDD and Domain Configuration as Required

```shell
# sed -i 's/MEM=2048/MEM=8192/g' ~/Microservice/Infrastructure-Setup/Create-Virtual-VM.sh
# sed -i 's/CPUS=2/CPUS=6/g' ~/Microservice/Infrastructure-Setup/Create-Virtual-VM.sh
# sed -i 's/SIZE=10G/SIZE=20G/g' ~/Microservice/Infrastructure-Setup/Create-Virtual-VM.sh
# sed -i 's/DOMAIN=example.com/DOMAIN=lab.example.com/g' ~/Microservice/Infrastructure-Setup/Create-Virtual-VM.sh
```

##### Step 8: Create Instances

```shell
# sh ~/Microservice/Infrastructure-Setup/Create-Virtual-VM.sh master
```

### Create New Disk

```shell
# sh ~/Microservice/Infrastructure-Setup/Create-New-Disk.sh master vdb 20G
```

