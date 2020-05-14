# NFS Setup

##### Step 1: Install NFS Packages on Server Node:

```shell
yum install nfs-utils -y
```

##### Step 2: Configure NFS Service

```shell
mkdir -p /exports/registry
mkdir -p /exports/metrics
mkdir -p /exports/logging
chmod o+rwx /exports/registry/
chmod o+rwx /exports/metrics
chmod o+rwx /exports/logging
echo "/exports/registry   *(rw,sync)" >> /etc/exports
echo "/exports/metrics   *(rw,sync)" >> /etc/exports
echo "/exports/logging   *(rw,sync)" >> /etc/exports
```

##### Step 3: Start & Verify NFS Service Configuration

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

on all nodes verify the reachability of NFS service

```shell
showmount -e nfs.lab.example.com
```