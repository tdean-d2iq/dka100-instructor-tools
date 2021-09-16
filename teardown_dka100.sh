#!/bin/bash
#
# Tom Dean - D2iQ
# Created : 9/14/2021
# Last Updated : 9/14/2021
# Wrapper script to tear down DKP cluster(s) for DKA100 class
# Uses Arvind Bhoj's arbhoj/cluster-api-provider-preprovisioned-field project
# GitHub URL : https://github.com/arbhoj/cluster-api-provider-preprovisioned-field

# Let's define some variables!
# We're going to count our student directories
numstudents=`ls -d student* | wc -l`
course=dka100

# Let's go!
echo "Destroying clusters for "$numstudents" students..."
echo
for i in `seq 1 $numstudents`
do echo "Destroying cluster for student"$i"..."
echo

# Let's set some variables inside the loop
userid=student$i
CLUSTER_NAME=$userid-$course

# Change to the student's directory
cd student$i

# Tell Terraform to tear down this student's cluster
terraform -chdir=provision apply -destroy -auto-approve -var-file ../student$i.tfvars

# Clean up SSH keys
eval `ssh-agent`
ssh-add -d ./$CLUSTER_NAME

# Back that thing up
echo
cd ..

# Let's do it again or GTFO!
done

# Now we're done, send a clean exit code
exit 0
