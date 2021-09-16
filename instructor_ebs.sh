#!/bin/bash
#
# Tom Dean - D2iQ
# Created : 9/15/2021
# Last Updated : 9/17/2021
# Script to deploy EBS SCSI provisioner
# FOR INSTRUCTORS ONLY!  ;)
# This script takes NO arguments!

# Let's set some variables!
export KUBECONFIG=$(pwd)/admin.conf

# Deploy 'awsebscsiprovisioner'
helm repo add d2iq-stable https://mesosphere.github.io/charts/stable
helm repo update
helm install awsebscsiprovisioner d2iq-stable/awsebscsiprovisioner --values awsebscsiprovisioner_values.yaml
sleep 30
kubectl patch sc localvolumeprovisioner -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

# Now we're done, send a clean exit code
exit 0
