# Training Installation

##### Step 1: Now Create Your Own Inventory file for Ansible as following on master Node

```shell
# vim ~/inventory.ini
```

```
[OSEv3:children]
masters
nodes
etcd

[masters]
master.lab.example.com

[etcd]
master.lab.example.com

[nodes]
master.lab.example.com openshift_schedulable=true ansible_connection=local ansible_become=yes
worker1.lab.example.com openshift_schedulable=true openshift_node_labels="{'region': 'primary', 'zone': 'default'}"
worker2.lab.example.com openshift_schedulable=true openshift_node_labels="{'region': 'primary', 'zone': 'default'}"
infra1.lab.example.com openshift_schedulable=true openshift_node_labels="{'region': 'infra', 'zone': 'default'}"

[OSEv3:vars]
debug_level=4
ansible_ssh_user=root
openshift_enable_service_catalog=true
ansible_service_broker_install=flase

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


# put the router on dedicated infra1 node
openshift_hosted_router_selector='region=infra'
openshift_master_default_subdomain=apps.lab.example.com
openshift_public_hostname=master.lab.example.com

# put the image registry on dedicated infra1 node
openshift_hosted_registry_selector='region=infra'
```



##### Step 2: Use the below ansible playbook command to check the prerequisites to deploy OpenShift Cluster on master Node

```shell
# ansible-playbook -i ~/inventory.ini playbooks/prerequisites.yml
```





##### Step 3: Once prerequisites completed without any error use the below ansible playbook to Deploy OpenShift Cluster on master Node

```shell
# ansible-playbook -i ~/inventory.ini playbooks/deploy_cluster.yml
```

Now you have to wait approx 20-30 Minutes to complete the Installation





##### Step 4: Once the Installation is completed, Create a admin user in OpenShift with Password "Redhat@123" from master Node and assign cluster-admin Role to admin user

```shell
# htpasswd -c /etc/origin/master/htpasswd admin
    New password: Redhat@123
    Re-type new password: Redhat@123
# ls -l /etc/origin/master/htpasswd
# cat /etc/origin/master/htpasswd
# vim /etc/origin/master/master-config.yaml
      identityProviders:
      - challenge: true
        login: true
        mappingMethod: claim
        name: allow_all
        provider:
          apiVersion: v1
          kind: HTPasswdPasswordIdentityProvider		## changes this line
          file: /etc/origin/master/htpasswd			    ## changes this line
# systemctl restart origin-master-controllers.service
# systemctl restart origin-master-api.service
# oc adm policy add-cluster-role-to-user cluster-admin admin

```

##### Step 5: Use the below command to login as admin user on CLI

```bash
# oc completion bash >>/etc/bash_completion.d/oc_completion
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