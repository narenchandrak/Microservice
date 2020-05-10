# NFS Setup

##### Step 1: Install NFS Packages on Server Node:

```shell
# yum install nfs-utils -y
```

##### Step 2: Configure NFS Service

```shell
# mkdir -p /exports/registry
# chmod o+rwx /exports/registry/
# echo "/exports/registry   192.168.1.0/24(rw,sync)" >> /etc/exports
```

##### Step 3: Start & Verify NFS Service Configuration

```shell
# cat /etc/exports
# systemctl start nfs-server
# systemctl enable nfs-server
# showmount -e
# showmount -e master.lab.example.com
```

