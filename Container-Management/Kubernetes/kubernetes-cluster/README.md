# Installation of Kubernetes-Cluster

Step 1 — Install Ansible on base node:

    yum install -y ansible

Step 2 — check password-less login to kuberenets nodes

    cd ~/virt/kubernetes-cluster/

    ansible all -i hosts -m shell -a "date"

    Note: Enter yes continusly for ssh keys exchange

Step 3 — Install dependencies in all kuberenets nodes

    ansible-playbook -i hosts kube-dependencies.yml --syntax-check

    ansible-playbook -i hosts kube-dependencies.yml

Step 4 — Instate Kubeadm in kuberenet master node

    ansible-playbook -i hosts master.yml --syntax-check

    ansible-playbook -i hosts master.yml

Step 5 — Added slave nodes to master node

    ansible-playbook -i hosts slaves.yml --syntax-check

    ansible-playbook -i hosts slaves.yml

