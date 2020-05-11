# Pod Security Policies
1. Set up a namespace and a service account
   ```
   kubectl create namespace psp-example
   kubectl create serviceaccount -n psp-example fake-user
   kubectl create rolebinding -n psp-example fake-editor --clusterrole=edit --serviceaccount=psp-example:fake-user
   ```
2. Create 2 aliases
   ```
   alias kubectl-admin='kubectl -n psp-example'
   alias kubectl-user='kubectl --as=system:serviceaccount:psp-example:fake-user -n psp-example'
   ```
3. Create a policy
   ```
   kubectl-admin create -f example-psp.yaml
   ```
4. Create a pod using as the unprivileged user
   ```
   kubectl-user create -f- <<EOF
   apiVersion: v1
   kind: Pod
   metadata:
     name:      pause
   spec:
     containers:
       - name:  pause
         image: k8s.gcr.io/pause
   EOF
   ```
   Note: What happened? Although the PodSecurityPolicy was created, neither the pod’s service account nor fake-user have permission to use the new policy
   ```
   kubectl-user auth can-i use podsecuritypolicy/example
   no
   ```
5. Create the rolebinding to grant fake-user
   ```
   kubectl-admin create role psp:unprivileged \
       --verb=use \
       --resource=podsecuritypolicy \
       --resource-name=example
   role "psp:unprivileged" created
    
   kubectl-admin create rolebinding fake-user:psp:unprivileged \
       --role=psp:unprivileged \
       --serviceaccount=psp-example:fake-user
   rolebinding "fake-user:psp:unprivileged" created
    
   kubectl-user auth can-i use podsecuritypolicy/example
   yes
   ```
6. Now retry creating the pod from step 4
7. Create a privileged pod should still be denied
   ```
   kubectl-user create -f- <<EOF
   apiVersion: v1
   kind: Pod
   metadata:
   name:      privileged
   spec:
    containers:
      - name:  pause
        image: k8s.gcr.io/pause
        securityContext:
            privileged: true
   EOF
   ```
8. Delete the pod
   ```
   kubectl-user delete pod pause
   ```
9.

   
