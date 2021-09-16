# Deploying a DKP Cluster

## Deploy the Build Server

[Konvoy Image Builder](https://github.com/mesosphere/konvoy-image-builder)

Make sure you're in the `konvoy-image-builder` directory:
```
cd ~/konvoy-image-builder
```

Deploy the build environment. Select an image YAML file, depending on the operating system of the cluster you wish to build. In this case we are deploying with Flatcar Linux.
```
./konvoy-image provision --inventory-file /home/centos/provision/inventory.yaml  images/generic/flatcar.yaml
```

## Deploy DKP Cluster

First, change to the `centos` user's home directory, where the `dkp` command resides.
```
cd ~
```

First, we'll create a bootstrap cluster.
```
./dkp create bootstrap
```

Once our bootstrap cluster is up, add the secret containing the private key, which is used to connect to the hosts.
```
kubectl create secret generic student1-dka100-ssh-key --from-file=ssh-privatekey=/home/centos/student1-dka100
```

Next, create the pre-provisioned inventory resources.
```
kubectl apply -f /home/centos/provision/student1-dka100-preprovisioned_inventory.yaml
```

Then, create the manifest files for deploying the konvoy to the cluster. Note: if you are deploying a flatcar cluster then add the --os-hint=flatcar flag like this:
```
./dkp create cluster preprovisioned --cluster-name student1-dka100 --control-plane-endpoint-host tf-lb-20210915171546574000000006-1574343567.us-west-2.elb.amazonaws.com --os-hint=flatcar --control-plane-replicas 1 --worker-replicas 4 --dry-run -o yaml > deploy-dkp-student1-dka100.yaml
```

Next, we'll need to update all occurances of `cloud-provider=""` to `cloud-provider=aws`.
```
sed -i 's/cloud-provider\:\ \"\"/cloud-provider\:\ \"aws\"/' deploy-dkp-student1-dka100.yaml
```

Now, apply the deploy manifest to the bootstrap cluster.
```
kubectl apply -f deploy-dkp-student1-dka100.yaml
```

Run the following command to view the status of the deployment.
```
watch -n 1 ./dkp describe cluster -c student1-dka100
```
Use `CTRL-C` to exit the command once all resources are ready.


```
kubectl logs -f -n cappp-system deploy/cappp-controller-manager
```

After a couple of minutes, if there are no critical errors, run the following command to get the `admin` kubeconfig of the provisioned DKP cluster.
```
./dkp get kubeconfig -c student1-dka100 > admin.conf
```

Change the permissions on the `admin.conf` file to be more restrictive.
```
chmod 600 admin.conf
```

Set `admin.conf` as the current KUBECONFIG.
```
export KUBECONFIG=$(pwd)/admin.conf
```

Run the following to make sure all the nodes in the DKP cluster are in `Ready` state.
```
watch -n 1 kubectl get nodes
```
Use `CTRL-C` to exit the command once all nodes are in the `Ready` state.

## Optional: Deploy `awsebscsiprovisioner`

***This doesn't work yet as the YAML file is missing: Error: open awsebscsiprovisioner_values.yaml: no such file or directory***

Run the following commands:
```
helm repo add d2iq-stable https://mesosphere.github.io/charts/stable  
```
```
helm repo update
```
```
helm install awsebscsiprovisioner d2iq-stable/awsebscsiprovisioner --values awsebscsiprovisioner_values.yaml 
```
```
kubectl patch sc localvolumeprovisioner -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```

## Deploy Kommander

***This doesn't work either, fails with: Error: failed to download "kommander-bootstrap-v2.0.0.tgz" at version "v2.0.0" (hint: running `helm repo update` may help).  Tried a `helm repo update`.  No dice.***

Run the following commands:
```
export VERSION=v2.0.0
```
```
helm repo add d2iq-stable https://mesosphere.github.io/charts/stable
```
```
helm repo update
```
```
helm install -n kommander --create-namespace kommander-bootstrap kommander-bootstrap-${VERSION}.tgz --version=${VERSION}
```
