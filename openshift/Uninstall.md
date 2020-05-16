# Openshift Uninstall & Re-install

### Uninstall openshift

##### Step 1: To uninstall and erase a deployed OpenShift Container Platform, run the following playbook:

```shell
cd ~/openshift-ansible && ansible-playbook -i ~/inventory.ini playbooks/adhoc/uninstall.yml
```

##### Step 2: reboot all nodes

```shell
reboot
```

### Re-install openshift

##### Step 1: wipe docker storage and start docker 

```shell
rm -rf /var/lib/docker && wipefs --all /dev/vdb && docker-storage-setup && systemctl start docker && systemctl enable docker && systemctl status docker
```

##### Step 2: Use the below ansible playbook command to check the prerequisites to deploy OpenShift Cluster on master Node

```shell
cd ~/openshift-ansible && ansible-playbook -i ~/inventory.ini playbooks/prerequisites.yml
```

##### Step 3: Once prerequisites completed without any error use the below ansible playbook to Deploy OpenShift Cluster on master Node

```shell
cd ~/openshift-ansible && ansible-playbook -i ~/inventory.ini playbooks/deploy_cluster.yml
```

