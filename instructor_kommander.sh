#!/bin/bash
#
# Tom Dean - D2iQ
# Created : 9/15/2021
# Last Updated : 9/15/2021
# Script to deploy Kommander
# FOR INSTRUCTORS ONLY!  ;)
# This script takes NO arguments!

# Let's define some variables!
version=v2.0.0

# Download Kommander!
wget "https://mesosphere.github.io/kommander/charts/kommander-bootstrap-${version}.tgz"

# Deploy Kommander!
helm repo add d2iq-stable https://mesosphere.github.io/charts/stable
helm repo update
helm install -n kommander --create-namespace kommander-bootstrap kommander-bootstrap-${version}.tgz --version=${version}

# Now we're done, send a clean exit code
exit 0
