#!/bin/bash
#
# Tom Dean - D2iQ
# Created : 9/14/2021
# Last Updated : 9/21/2021
# Wrapper script to stand up DKP cluster(s) for DKA100 class - AWS East Region
# Uses Arvind Bhoj's arbhoj/cluster-api-provider-preprovisioned-field project
# GitHub URL : https://github.com/arbhoj/cluster-api-provider-preprovisioned-field

# Let's define some variables!
numstudents=$1
instructor=$2
course=dka100
branch=training
startnum=1
expiration=100h

# Let's go!
echo "Creating clusters for "$numstudents" students..."
echo

# Let's build a cluster for each student!
for i in `seq $startnum $numstudents`
do echo "Creating cluster for student"$i"..."
echo

# Create a directory for this student, and clone Arvind's repo to it
mkdir student$i
git clone --branch $branch https://github.com/arbhoj/cluster-api-provider-preprovisioned-field.git student$i
echo

# Set some variables inside the loop
userid=student$i
CLUSTER_NAME=$userid-$course

# Create ssh keys for the student
ssh-keygen -q -t rsa -N '' -f student$i/$CLUSTER_NAME <<<y 2>&1 >/dev/null

# Let's do some Terraform stuff!
# First, we're going to initialize Terraform.
cd student$i
terraform -chdir=provision init
echo

# Next, let's create a tfvars file for this student
cat <<EOF > student$i.tfvars
tags = {
  "owner" : "student$i",
  "expiration" : "$expiration"
  "instructor" : "$instructor"
  "student" : "student$i"
  "course" : "$course"
  "courseadmin" : "$USER"
  "company" : "D2iQ"
}
aws_region = "us-east-1"
aws_availability_zones = ["us-east-1c"]
node_ami = "ami-048e383eb95db98c4"
registry_ami = "ami-00e87074e52e6c9f9"
ansible_python_interpreter = "/opt/bin/python"
ssh_username = "core"
create_iam_instance_profile = true
cluster_name = "$CLUSTER_NAME"
ssh_private_key_file = "../$CLUSTER_NAME"
ssh_public_key_file = "../$CLUSTER_NAME.pub"
create_extra_worker_volumes = true
extra_volume_size = 500
EOF
echo

# Let's add our ssh information
eval `ssh-agent`
ssh-add $CLUSTER_NAME
echo

# Time to create this student's cluster!
terraform -chdir=provision apply -auto-approve -var-file ../student$i.tfvars

# Let's dump the Terraform output to a text file in the student's directory for referemce
terraform -chdir=provision output > student$i\_output.txt

# Let's pause for 30 seconds
sleep 30

# Back out of this student's directory so we can do it all again, or wind up where we started
echo
cd ..

# Let's do it again or GTFO!
done
echo

# Create zip files for each student that contain documents, SSH keys, etc.
echo "Creating zipfiles for students..."
echo

# Create directory to hold zip files
mkdir $course\_student\_assets

# Create zip files
for i in `seq 1 $numstudents`
do echo "Creating zipfile for student"$i"..."
echo
zip -r $course\_student\_assets/student$i.zip student$i/student$i-$course student$i/student$i-$course.pub student$i/student$i\_output.txt

# Create the next file or GTFO!
done
echo

# Create a zipfile from the $course_student_assets directory
zip -r $course\_student\_assets.zip $course\_student\_assets

# Now we're done, send a clean exit code
exit 0
