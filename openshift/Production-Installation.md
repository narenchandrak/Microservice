# Production Installation

##### Step 1: Now Create Your Own Inventory file for Ansible as following on master Node

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
master.lab.example.com

[etcd]
master.lab.example.com

[nfs]
nfs.lab.example.com

[nodes]
master.lab.example.com openshift_schedulable=true
worker1.lab.example.com openshift_schedulable=true openshift_node_labels="{'region': 'primary', 'zone': 'default'}"
worker2.lab.example.com openshift_schedulable=true openshift_node_labels="{'region': 'primary', 'zone': 'default'}"
infra1.lab.example.com openshift_schedulable=true openshift_node_labels="{'region': 'infra', 'zone': 'default'}"

[OSEv3:vars]
debug_level=4
ansible_ssh_user=root
openshift_enable_service_catalog=true
ansible_service_broker_install=true
openshift_metrics_install_metrics=true
openshift_logging_install_logging=true

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
openshift_cockpit_deployer_prefix='registry.access.redhat.com/openshift3/'
openshift_cockpit_deployer_basename='registry-console'
openshift_cockpit_deployer_version='v3.9'


# Login Details paswword Configuration
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]

# put the router on dedicated infra1 node
openshift_hosted_router_selector='region=infra'
openshift_master_default_subdomain=apps.lab.example.com
openshift_public_hostname=master.lab.example.com
openshift_master_api_port=8443
openshift_master_console_port=8443

# put the image registry on dedicated infra1 node
openshift_hosted_registry_selector='region=infra'

# NFS Configuration for Registry
openshift_enable_unsupported_configurations=True
openshift_hosted_registry_storage_kind=nfs
openshift_hosted_registry_storage_access_modes=['ReadWriteMany']
openshift_hosted_registry_storage_nfs_directory=/exports
openshift_hosted_registry_storage_nfs_options='*(rw,root_squash)'
openshift_hosted_registry_storage_volume_name=registry
openshift_hosted_registry_storage_volume_size=10Gi

openshift_hosted_etcd_storage_kind=nfs
openshift_hosted_etcd_storage_nfs_options="*(rw,root_squash,sync,no_wdelay)"
openshift_hosted_etcd_storage_nfs_directory=/exports
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
```

Reference:

1. https://docs.okd.io/3.9/install_config/install/advanced_install.html

##### Step 2: Create a admin user in OpenShift with Password "Redhat@123" from master Node

```shell
# mkdir -p /etc/origin/master/
# touch /etc/origin/master/htpasswd
# htpasswd -b /etc/origin/master/htpasswd admin Redhat@123
# ls -l /etc/origin/master/htpasswd
# cat /etc/origin/master/htpasswd
```

##### Step 3: Use the below ansible playbook command to check the prerequisites to deploy OpenShift Cluster on master Node

```shell
# ansible-playbook -i ~/inventory.ini playbooks/prerequisites.yml
```





##### Step 4: Once prerequisites completed without any error use the below ansible playbook to Deploy OpenShift Cluster on master Node

```shell
# ansible-playbook -i ~/inventory.ini playbooks/deploy_cluster.yml
```

Now you have to wait approx. 60-80 Minutes to complete the Installation





##### Step 5: Once the Installation is completed, assign cluster-admin Role to admin user

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