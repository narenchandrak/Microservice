#!/usr/bin/env bash
if ! [[ $# -eq 3 ]]; then
    echo "Usage: $0 <node-name> <disk-name> <disk-size>"
    echo "Example:"
    echo "$0 master vdb 20G"
    exit 1
fi

DISK="/var/lib/libvirt/images/$1-$2.qcow2"
SIZE=$3
echo "$(date -R) Creating Empty RAW $2 with size of $SIZE"
qemu-img create -f raw ${DISK} ${SIZE}
virsh attach-disk $1 --source ${DISK} --target $2 --persistent
if [[ "$?" -eq 0 ]]; then
    echo "$(date -R) Successfully new $2 disk attached to $1 VM"
else
    echo "$(date -R)  Failed to attach the  new $2 disk to $1 VM"
fi