# NFS Setup

##### Step 1: Install NFS Server Packages:

```shell
# yum install nfs-utils -y
```

##### Step 2: Configure NFS Server

```shell
# mkdir -p /shares/registry
# chmod o+rwx /shares/registry/
# echo "/shares/registry   192.168.1.0/24(rw,sync)" >> /etc/exports
```

##### Step 3: Start & Verify NFS Server Configuration

```shell
# cat /etc/exports
# systemctl start nfs-server
# systemctl enable nfs-server
# showmount -e
# showmount -e master.lab.example.com
```

