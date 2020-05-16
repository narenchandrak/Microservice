# Openshift LAB Exercise

### LAB 1:

Configure authentication on your OpenShift instance so that:

- The password file is /etc/origin/master/htpasswd
- The user randy exists with password redhat
- The user sam exists with password redhat
- Both users must be able to authenticate to the Openshift Instance via CLI and on the Web Console at https://master.lab.example.com:8443
- No user should be able to create any project

##### Solution:

```
oc adm policy add-cluster-role-to-user cluster-admin admin

htpasswd  -b /etc/origin/master/htpasswd  sam  redhat

htpasswd  -b  /etc/origin/master/htpasswd  randy redhat

oc adm policy remove-cluster-role-from-group self-provisioner  system:authenticated:oauth
```



To Check:

```
oc get user
oc get identity
oc describe user/<username>
oc delete user <username>
```

References:

1. https://docs.okd.io/3.9/admin_guide/manage_users.html
2. https://docs.okd.io/3.9/admin_guide/manage_rbac.html



### LAB 2:

Configure project on your Openshift  platform

- Create new projects farm, ditto, space, sample and rome
- Description should be “This is an LAB2 project on OpenShift v3”
- Make randy the admin of rome and space. 
- Provide sam the view permission to rome. 
- Make sam the admin of farm, ditto & sample.

Solution:

```shell
oc new-project --description=“This is an LAB2 project on OpenShift v3” rome

oc new-project --description=“This is an LAB2 project on OpenShift v3” space

oc new-project --description=“This is an LAB2 project on OpenShift v3” farm

oc new-project --description=“This is an LAB2 project on OpenShift v3” sample

oc new-project --description=“This is an LAB2 project on OpenShift v3” ditto

oc get projects

oc adm policy add-role-to-user admin randy -n rome

oc adm policy add-role-to-user admin randy -n space

oc adm policy add-role-to-user view sam -n rome

oc adm policy add-role-to-user admin sam -n ditto

oc adm policy add-role-to-user admin sam -n sample

oc adm policy add-role-to-user admin sam -n farm

oc get rolebinding -n <projectname> 
```



References:

1. https://docs.okd.io/3.9/admin_guide/managing_projects.html