#!/bin/bash


## Default variables to use
export INTERACTIVE=${INTERACTIVE:="true"}
export PVS=${PVS:="true"}
export DOMAIN=${DOMAIN:="example.com"}
export USERNAME=${USERNAME:="$(whoami)"}
export PASSWORD=${PASSWORD:=password}
export VERSION=${VERSION:="3.11"}
export SCRIPT_REPO=${SCRIPT_REPO:="https://raw.githubusercontent.com/okd-community-install/installcentos/master"}
export IP=${IP:="$(ip route get 8.8.8.8 | awk '{print $NF; exit}')"}
export API_PORT=${API_PORT:="8443"}
export DISK=${DISK:="sdb"}

## Make the script interactive to set the variables
if [ "$INTERACTIVE" = "true" ]; then
	read -rp "Domain to use: ($DOMAIN): " choice;
	if [ "$choice" != "" ] ; then
		export DOMAIN="$choice";
	fi

	read -rp "Username: ($USERNAME): " choice;
	if [ "$choice" != "" ] ; then
		export USERNAME="$choice";
	fi

	read -rp "Password: ($PASSWORD): " choice;
	if [ "$choice" != "" ] ; then
		export PASSWORD="$choice";
	fi

	read -rp "OpenShift Version: ($VERSION): " choice;
	if [ "$choice" != "" ] ; then
		export VERSION="$choice";
	fi
	read -rp "IP: ($IP): " choice;
	if [ "$choice" != "" ] ; then
		export IP="$choice";
	fi

	read -rp "API Port: ($API_PORT): " choice;
	if [ "$choice" != "" ] ; then
		export API_PORT="$choice";
	fi
	
	read -rp "Docker storage Device: ($DISK): " choice;
	if [ "$choice" != "" ] ; then
		export DISK="$DISK";
	fi
	
	read -rp "PV Creation: ($PVS): " choice;
	if [ "$choice" != "" ] ; then
		export PVS="$PVS";
	fi

fi

echo "******"
echo "* Your domain is $DOMAIN "
echo "* Your IP is $IP "
echo "* Your username is $USERNAME "
echo "* Your password is $PASSWORD "
echo "* OpenShift version: $VERSION "
echo "* Docker Storage Device: $DISK "
echo "******"

# install updates
yum update -y

# install the following base packages
yum install -y  wget git zile nano net-tools docker-1.13.1\
				bind-utils iptables-services \
				bridge-utils bash-completion \
				kexec-tools sos psacct openssl-devel \
				httpd-tools NetworkManager \
				python-cryptography python2-pip python-devel  python-passlib \
				java-1.8.0-openjdk-headless "@Development Tools"

#install epel
yum -y install epel-release

# Disable the EPEL repository globally so that is not accidentally used during later steps of the installation
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo

systemctl | grep "NetworkManager.*running"
if [ $? -eq 1 ]; then
	systemctl start NetworkManager
	systemctl enable NetworkManager
fi

# install the packages for Ansible
yum -y --enablerepo=epel install pyOpenSSL

curl -o ansible.rpm https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.6.5-1.el7.ans.noarch.rpm
yum -y --enablerepo=epel install ansible.rpm

[ ! -d openshift-ansible ] && git clone https://github.com/openshift/openshift-ansible.git -b release-${VERSION} --depth=1

cat <<EOD > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
${IP}		$(hostname) console console.${DOMAIN}
EOD

if [ -z $DISK ]; then
	echo "Not setting the Docker storage."
else
	cp /etc/sysconfig/docker-storage-setup /etc/sysconfig/docker-storage-setup.bk

	echo DEVS=$DISK > /etc/sysconfig/docker-storage-setup
	echo VG=DOCKER >> /etc/sysconfig/docker-storage-setup
	echo SETUP_LVM_THIN_POOL=yes >> /etc/sysconfig/docker-storage-setup
	echo DATA_SIZE="100%FREE" >> /etc/sysconfig/docker-storage-setup

	systemctl stop docker

	rm -rf /var/lib/docker
	wipefs --all $DISK
	docker-storage-setup
fi

systemctl restart docker
systemctl enable docker

if [ ! -f ~/.ssh/id_rsa ]; then
	ssh-keygen -q -f ~/.ssh/id_rsa -N ""
	cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
	ssh -o StrictHostKeyChecking=no root@$IP "pwd" < /dev/null
fi

export METRICS="True"
export LOGGING="True"

memory=$(cat /proc/meminfo | grep MemTotal | sed "s/MemTotal:[ ]*\([0-9]*\) kB/\1/")

if [ "$memory" -lt "4194304" ]; then
	export METRICS="False"
fi
if [ "$memory" -lt "16777216" ]; then
	export LOGGING="False"
fi

mkdir -p /etc/origin/master/
touch /etc/origin/master/htpasswd


cat << EOF > inventory.ini
[OSEv3:children]
masters
nodes
etcd
nfs

[masters]
${IP} openshift_ip=${IP} openshift_schedulable=true 

[etcd]
${IP} openshift_ip=${IP}

[nfs]
${IP} openshift_ip=${IP}

[nodes]
${IP} openshift_ip=${IP} openshift_schedulable=true openshift_node_group_name="node-config-all-in-one"

[OSEv3:vars]
debug_level=4
ansible_ssh_user=root
openshift_enable_service_catalog=true
ansible_service_broker_install=true
openshift_metrics_install_metrics=${METRICS}
openshift_logging_install_logging=${LOGGING}

containerized=False
os_sdn_network_plugin_name='redhat/openshift-ovs-multitenant'
openshift_disable_check=disk_availability,docker_storage,memory_availability,docker_image_availability

deployment_type=origin
openshift_deployment_type=origin

openshift_release="v${VERSION}.0"
openshift_pkg_version="-${VERSION}.0"
openshift_image_tag="v${VERSION}.0"
openshift_service_catalog_image_version="v${VERSION}.0"
template_service_broker_image_version="v${VERSION}"
openshift_metrics_image_version="v${VERSION}"
openshift_logging_image_version="v${VERSION}"
openshift_logging_elasticsearch_proxy_image_version="v1.0.0"
osm_use_cockpit=true


openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]
openshift_master_htpasswd_file='/etc/origin/master/htpasswd'

openshift_public_hostname=console.${DOMAIN}
openshift_master_default_subdomain=apps.${DOMAIN}
openshift_master_api_port=${API_PORT}
openshift_master_console_port=${API_PORT}

# Local NFS Configuration
openshift_enable_unsupported_configurations=True
openshift_hosted_registry_storage_kind=nfs
openshift_hosted_registry_storage_access_modes=['ReadWriteMany']
openshift_hosted_registry_storage_nfs_directory=/exports
openshift_hosted_registry_storage_nfs_options='*(rw,root_squash)'
openshift_hosted_registry_storage_volume_name=registry
openshift_hosted_registry_storage_volume_size=10Gi

openshift_hosted_etcd_storage_kind=nfs
openshift_hosted_etcd_storage_nfs_options="*(rw,root_squash,sync,no_wdelay)"
openshift_hosted_etcd_storage_nfs_directory=/opt/osev3-etcd 
openshift_hosted_etcd_storage_volume_name=etcd-vol2 
openshift_hosted_etcd_storage_access_modes=["ReadWriteOnce"]
openshift_hosted_etcd_storage_volume_size=1G
openshift_hosted_etcd_storage_labels={'storage': 'etcd'}

openshift_metrics_storage_kind=nfs
openshift_metrics_storage_access_modes=['ReadWriteOnce']
openshift_metrics_storage_nfs_directory=/exports
openshift_metrics_storage_nfs_options='*(rw,root_squash)'
openshift_metrics_storage_volume_name=metrics
openshift_metrics_storage_volume_size=10Gi

openshift_logging_storage_kind=nfs
openshift_logging_storage_access_modes=['ReadWriteOnce']
openshift_logging_storage_nfs_directory=/exports 
openshift_logging_storage_nfs_options='*(rw,root_squash)' 
openshift_logging_storage_volume_name=logging
openshift_logging_storage_volume_size=10Gi
openshift_logging_elasticsearch_storage_type=pvc
openshift_logging_es_pvc_size=10Gi
openshift_logging_es_pvc_storage_class_name=''
openshift_logging_es_pvc_dynamic=true
openshift_logging_es_pvc_prefix=logging
EOF

ansible-playbook -i inventory.ini openshift-ansible/playbooks/prerequisites.yml
if [ $? -eq 0 ]; then
	echo "openshift pre-request completed"
else
	exit 1;
fi
ansible-playbook -i inventory.ini openshift-ansible/playbooks/deploy_cluster.yml
if [ $? -eq 0 ]; then
	echo "openshift installed"
else
	exit 1;
fi


htpasswd -b /etc/origin/master/htpasswd ${USERNAME} ${PASSWORD}
oc adm policy add-cluster-role-to-user cluster-admin ${USERNAME}

if [ "$PVS" = "true" ]; then

	curl -o vol.yaml $SCRIPT_REPO/vol.yaml

	for i in `seq 1 20`;
	do
		DIRNAME="vol$i"
		mkdir -p /mnt/data/$DIRNAME
		chcon -Rt svirt_sandbox_file_t /mnt/data/$DIRNAME
		chmod 777 /mnt/data/$DIRNAME

		sed "s/name: vol/name: vol$i/g" vol.yaml > oc_vol.yaml
		sed -i "s/path: \/mnt\/data\/vol/path: \/mnt\/data\/vol$i/g" oc_vol.yaml
		oc create -f oc_vol.yaml
		echo "created volume $i"
	done
	rm oc_vol.yaml
fi

echo "******"
echo "* Your console is https://console.$DOMAIN:$API_PORT"
echo "* Your username is $USERNAME "
echo "* Your password is $PASSWORD "
echo "*"
echo "* Login using:"
echo "*"
echo "$ oc login -u ${USERNAME} -p ${PASSWORD} https://console.$DOMAIN:$API_PORT/"
echo "******"

oc login -u ${USERNAME} -p ${PASSWORD} https://console.$DOMAIN:$API_PORT/