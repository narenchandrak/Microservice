#!/usr/bin/env bash

function USAGE() {
cat << EOF
Usage: $0 [-h HELP] [-o OPERATION] [-n NAME] [-d DOMAIN] [-c CPU] [-r RAM] [-v VOLUMES]

        -h  HELP        display this help and exit
        -o  OPERATION   Type of Virtual Operation
                        create  - Create Virtual VM
                        delete  - Delete Virtual VM
        -n NAME         Name of the VMM
        -d DOMAIN       Domain name for VM
        -c CPU          No of vCPU for VM
        -r RAM          Total RAM for VM in MB
        -v VOLUME       size of the volume
 Example:
        $0 -o create -n master -d example.com -c 2 -r 2048 -v 100G
EOF
}

function CREAT_VM() {

    LOG "INFO VM Creation Started for ${hostname}"
    # Start clean
    rm -rf ${DIR}/${hostname}
    mkdir -p ${DIR}/${hostname}

    if [[ -f ${IMAGE} ]];then
        LOG "INFO ${IMAGE} is already exists"
    else
        LOG "INFO ${IMAGE} not exists"
        mkdir -p ~/Microservice/images
        pushd ~/Microservice/images > /dev/null
        LOG "INFO Download Latest centos Images"
        wget http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2.xz 2>&1 | tee -a ~/Microservice/Infrastructure-Setup/Virtual_Infrastructure.log
        xz --decompress CentOS-7-x86_64-GenericCloud.qcow2.xz 2>&1 | tee -a ~/Microservice/Infrastructure-Setup/Virtual_Infrastructure.log
        popd > /dev/null
    fi

    VM_CHECK
    VOLUME_CREATION

    LOG "INFO Installing the domain and adjusting the configuration..."
    LOG "INFO Installing with the following parameters:"
    echo "virt-install --import --name ${hostname} --ram $MEM --vcpus $CPUS --disk
    $DISK,format=qcow2,bus=virtio --disk $CI_ISO,device=cdrom --network
    bridge=virbr0,model=virtio --os-type=linux --os-variant=rhel7 --noautoconsole" 2>&1 | tee -a ~/Microservice/Infrastructure-Setup/Virtual_Infrastructure.log

    virt-install --import --name ${hostname} --ram ${MEM} --vcpus ${CPUS} --disk \
    ${DISK},format=qcow2,bus=virtio --disk ${CI_ISO},device=cdrom --network \
    bridge=virbr0,model=virtio --os-type=linux --os-variant=rhel7 --noautoconsole 2>&1 | tee -a ~/Microservice/Infrastructure-Setup/Virtual_Infrastructure.log

    MAC=$(virsh dumpxml ${hostname} | awk -F\' '/mac address/ {print $2}')
    while true
    do
        IP=$(grep -B1 ${MAC} /var/lib/libvirt/dnsmasq/${BRIDGE}.status | head \
             -n 1 | awk '{print $2}' | sed -e s/\"//g -e s/,//)
        if [[ "$IP" = "" ]]
        then
            sleep 1
        else
            break
        fi
    done

    # Eject cdrom
    LOG "INFO Cleaning up cloud-init..."
    virsh change-media ${hostname} hda --eject --config 2>&1 | tee -a ~/Microservice/Infrastructure-Setup/Virtual_Infrastructure.log

    # Remove the unnecessary cloud init files
    rm ${USER_DATA} ${CI_ISO}

    LOG "INFO DONE. SSH to ${hostname} using $IP, with  username 'root'."
    LOG "INFO Adding $IP ${hostname}.$DOMAIN in /etc/hosts"
    sed -i '/'${hostname}'.'${DOMAIN}'/d' /etc/hosts
    if [[ $? -eq 0 ]]; then
        echo "$IP ${hostname}.$DOMAIN ${hostname}" >> /etc/hosts
        LOG "successfully added value in /etc/hosts"
    else
        echo "Failed to $IP value in /etc/hosts. Please add manually in /etc/hosts"
    fi
}

function DELETE_VM() {
    VM_CHECK
}

function VM_CHECK() {
    LOG "INFO Checking VM already exists"
    virsh dominfo ${hostname}
    if [[ "$?" -eq 0 ]]; then
        LOG "WARNING ${hostname} VM already exists."
        read -p "Do you want to overwrite ${hostname} [y/N]? " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            LOG "INFO Destroying the ${hostname} VM."
            virsh destroy ${hostname} 2>&1 | tee -a ~/Microservice/Infrastructure-Setup/Virtual_Infrastructure.log
            virsh undefine ${hostname} 2>&1 | tee -a ~/Microservice/Infrastructure-Setup/Virtual_Infrastructure.log
        else
            LOG "INFO Not overwriting ${hostname} VM. Exiting..."
            exit 1
        fi
    fi
}

function VOLUME_CREATION() {

    echo "instance-id: ${hostname}; local-hostname: ${hostname}" > ${META_DATA}

    LOG "INFO Copying template image to $DISK"
    cp ${IMAGE} ${DISK} 2>&1 | tee -a ~/Microservice/Infrastructure-Setup/Virtual_Infrastructure.log
    LOG "INFO Resizing $DISK VM Volume to $SIZE"
    qemu-img resize ${DISK} ${SIZE} 2>&1 | tee -a ~/Microservice/Infrastructure-Setup/Virtual_Infrastructure.log

    # cloud-init config: set hostname, remove cloud-init package,
    # and add ssh-key
    cat > ${USER_DATA} << _EOF_
#cloud-config

# Hostname management
preserve_hostname: False
hostname: ${hostname}
fqdn: ${hostname}.${DOMAIN}

# Remove cloud-init when finished with it
runcmd:
  - [ yum, -y, remove, cloud-init ]

# Configure where output will go
output:
  all: ">> /var/log/cloud-init.log"

#added
debug: True
ssh_pwauth: True
disable_root: false
chpasswd:
  list: |
    root:redhat
  expire: False
runcmd:
  - sed -i'.orig' -e's/without-password/yes/' /etc/ssh/sshd_config
  - service sshd restart

# configure interaction with ssh server
ssh_svcname: ssh
ssh_deletekeys: True
ssh_genkeytypes: ['rsa', 'ecdsa']

# Install my public ssh key to the first user-defined user configured
# in cloud.cfg in the template (which is centos for CentOS cloud images)
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKvZaXfROgVvuGqsWNVLOWvhlMeMBiWZ3JwxLUgfUzUl66PXPxH5z1gngG832rIWXbIWWPBdc/xB46zjxDA62ecydZ70e72lTWqytuNBEkotSAw6S2M2VCOAUv/VKsZq3SFenW6Alhn9iVrbjscw/vpLz6nQghktng0uzmXnT5sAw4k1rgG2M71JN+82qAPpelLta/Vc21dYFBWGYfVS9rwcGqPloDtYmFi2Iyz7GVaJPnM2tC4xn1UYssATE0i7kwaLMtJGu9kP6LHIKTxJEkNa9khF9+GtyIZ0dLtuzdBE/LYz8N3dYJ+6CvpBYAMV/Rm00Yp2i2s/+YUua2FgQ9 root@workstation.lab.example.com
_EOF_


    # Create CD-ROM ISO with cloud-init config
    LOG "INFO Generating ISO for cloud-init..."
    genisoimage -output ${CI_ISO} -volid cidata -joliet -r ${USER_DATA} ${META_DATA} 2>&1 | tee -a ~/Microservice/Infrastructure-Setup/Virtual_Infrastructure.log
}


function LOG() {
    # LOG "INFO some info message"
    # LOG "DEBUG some debug message"
    # LOG "WARN some warning message"
    # LOG "ERROR some really ERROR message"
    # LOG "FATAL some really fatal message"
    type_of_msg=$(echo $*|cut -d" " -f1)
    msg=$(echo "$*"|cut -d" " -f2-)
    echo "$(date -R) [$type_of_msg] $msg" 2>&1 | tee -a ~/Microservice/Infrastructure-Setup/Virtual_Infrastructure.log
}

###
# Main body of script starts here
###

while getopts ":o:n:d:c:r:v:h" OPT; do
    case "${OPT}" in
    "o")
        operation=${OPTARG}
        ;;
    "n")
        hostname=${OPTARG}
        ;;
    "d")
        DOMAIN=${OPTARG}
        ;;
    "c")
        CPUS=${OPTARG}
        ;;
    "r")
        MEM=${OPTARG}
        ;;
    "v")
        SIZE=${OPTARG}
        ;;
    "h")
        USAGE
        exit 0
        ;;
    esac
done

# Directory to store images
DIR=~/Microservice/images/

# Location of cloud image
IMAGE=${DIR}/CentOS-7-x86_64-GenericCloud.qcow2

# Cloud init files
USER_DATA=${DIR}/${hostname}/user-data
META_DATA=${DIR}/${hostname}/meta-data
CI_ISO="/var/lib/libvirt/images/${hostname}-cidata.iso"
DISK="/var/lib/libvirt/images/${hostname}.qcow2"

# Bridge for VMs (default on centos is virbr0)
BRIDGE=virbr0

if ! [[ -f ~/Microservice/Infrastructure-Setup/Virtual_Infrastructure.log ]]; then
    touch ~/Microservice/Infrastructure-Setup/Virtual_Infrastructure.log
fi

if [[ ${operation} -eq "create" ]]; then
    CREAT_VM
elif [[ ${operation} -eq "delete" ]]; then
    DELETE_VM
else
    LOG "ERROR The following ${OPTARG} operation is not available"
    USAGE
    exit 1
fi