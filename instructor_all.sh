#!/bin/bash
#
# Tom Dean - D2iQ
# Created : 9/15/2021
# Last Updated : 9/17/2021
# Script to deploy DKP cluster, EBS SCSI Provisioner and Kommander
# FOR INSTRUCTORS ONLY!  ;)
# This script takes TWO arguments:
# 	- First argument is the student userid (eg: student1)
#	- Second argument is the kube_apiserver_address, or the ELB DNS name

# Let's set some variables!
student=$1
control_plane=$2
version=v2.0.0
class=dka100
cp_replicas=1
wk_replicas=4

# Deploy the Build Server
cd ~/konvoy-image-builder
./konvoy-image provision --inventory-file /home/centos/provision/inventory.yaml  images/generic/flatcar.yaml


# Deploy DKP Cluster
cd ~
./dkp create bootstrap
kubectl create secret generic $student-$class-ssh-key --from-file=ssh-privatekey=/home/centos/$student-$class
kubectl apply -f /home/centos/provision/$student-$class-preprovisioned_inventory.yaml
./dkp create cluster preprovisioned --cluster-name $student-$class --control-plane-endpoint-host $control_plane --os-hint=flatcar --control-plane-replicas $cp_replicas --worker-replicas $wk_replicas --dry-run -o yaml > deploy-dkp-$student-$class.yaml
sed -i 's/cloud-provider\:\ \"\"/cloud-provider\:\ \"aws\"/' deploy-dkp-$student-$class.yaml
kubectl apply -f deploy-dkp-$student-$class.yaml
watch -n 1 ./dkp describe cluster -c $student-$class
#kubectl logs -f -n cappp-system deploy/cappp-controller-manager
./dkp get kubeconfig -c $student-$class > admin.conf
chmod 600 admin.conf
export KUBECONFIG=$(pwd)/admin.conf
watch -n 1 kubectl get nodes

# Deploy 'awsebscsiprovisioner'
helm repo add d2iq-stable https://mesosphere.github.io/charts/stable
helm repo update
helm install awsebscsiprovisioner d2iq-stable/awsebscsiprovisioner --values awsebscsiprovisioner_values.yaml
sleep 30
kubectl patch sc localvolumeprovisioner -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

# Download Kommander!
wget "https://mesosphere.github.io/kommander/charts/kommander-bootstrap-${version}.tgz"

# Deploy Kommander!
helm repo add d2iq-stable https://mesosphere.github.io/charts/stable
helm repo update
helm install -n kommander --create-namespace kommander-bootstrap kommander-bootstrap-${version}.tgz --version=${version}

# Now we're done, send a clean exit code
exit 0
