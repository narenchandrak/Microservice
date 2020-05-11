# Helm Introduction and Installation

Helm is a package manager for Kubernetes that allows developers and operators to more easily configure and deploy applications on Kubernetes clusters.

In this tutorial we will set up Helm and use it to install, reconfigure, rollback, then delete an instance of the Kubernetes Dashboard application. The dashboard is an official web-based Kubernetes GUI.

For a conceptual overview of Helm and its packaging ecosystem, please read our article An Introduction to Helm.
Prerequisites

For this tutorial you will need:

A Kubernetes 1.8+ cluster with role-based access control (RBAC) enabled.

The kubectl command-line tool installed on your local machine, configured to connect to your cluster. You can read more about installing kubectl in the official documentation.

You can test your connectivity with the following command:

        kubectl cluster-info

Step 1 — Installing Helm

First we'll install the helm command-line utility on our local machine. Helm provides a script that handles the installation process on MacOS, Windows, or Linux.

Change to a writable directory and download the script from Helm's GitHub repository:

        cd /tmp
        curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > install-helm.sh

Make the script executable with chmod:

        chmod u+x install-helm.sh

At this point you can use your favorite text editor to open the script and inspect it to make sure it’s safe. When you are satisfied, run it:

        ./install-helm.sh

You may be prompted for your password. Provide it and press ENTER.

Step 2 — Installing Tiller

Tiller is a companion to the helm command that runs on your cluster, receiving commands from helm and communicating directly with the Kubernetes API to do the actual work of creating and deleting resources. To give Tiller the permissions it needs to run on the cluster, we are going to make a Kubernetes serviceaccount resource.

Create the tiller serviceaccount:

        kubectl -n kube-system create serviceaccount tiller

Next, bind the tiller serviceaccount to the cluster-admin role:

        kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

Now we can run helm init, which installs Tiller on our cluster, along with some local housekeeping tasks such as downloading the stable repo details:

        helm init --service-account tiller
