# Using the DKA100 Instructor Tools

[DKA100 Instructor Tools GitHub](https://github.com/tdean-d2iq/dka100-instructor-tools)

[Arvind's cluster-api-provider-preprovisioned-field GitHub Repository](https://github.com/arbhoj/cluster-api-provider-preprovisioned-field) - We use the `training` branch of this repository

The DKA100 Instructor Tools kit contains scripts for deploying DKA100 student lab environments for the DKA100 class.  The kit also can deploy a DKP/Kommander environment in an automated fashion.  This can be handy if you need to catch up with students, have a student with a failed installation, etc.

The following scripts are provided:
- `setup_dka100_[east/west].sh` : these scripts create the DKA100 student lab environments in AWS - ***USE ONE ONLY***
    - Use the East script for the `us-east-1` region, the West script for `us-west-2`
    - First argument: number of clusters/students (optional - defaults to 1)
    - Second argument: instuctor userid (optional)
- `teardown_dka100.sh` : this script is for cleaning up the DKA100 student lab environments
- `instructor_dkp.sh` : this script is for automated deployment of the DKP environment
    - First argument: studentX
    - Second argument: ELB DNS
- `instructor_ebs.sh` : this script deploys the AWS EBS SCSI Provisioner
- `instructor_kommander.sh` : this script is for automated deployment of Kommander
- `instructor_all.sh` : this script does it all: DKP, EBS and Kommander
    - First argument: studentX
    - Second argument: ELB DNS

## Checking Out the DKA100 Instructor Tools Repository from GitHub

First, I would recommend creating a new directory to contain all the class materials.
```
mkdir dka100
```
```
cd dka100
```

Second, let's clone the DKA100 Instructor Tools.
```
git clone https://github.com/tdean-d2iq/dka100-instructor-tools.git
```

Next, let's make the scripts executable.
```
chmod 755 dka100-instructor-tools/*.sh
```

## Standing Up Student Clusters

***You should refresh your AWS credentials at this point, just in case.***

### Let's deploy the student clusters!

The `setup_dka100.sh` script takes up to two arguments.  The *first* argument is the number of **students/clusters** you wish to deploy, which can be a value of `1` or greater.  The *second* argument is for an `instructor` tag, which you can put any string into.  This will assist you if you need to locate resources based on that tag.
```
./dka100-instructor-tools/setup_dka100.sh 3 tdean
```

The `setup_dka100.sh` script can be run with no arguments, which will give us a *single* cluster, without an *instructor* tag.
```
./dka100-instructor-tools/setup_dka100.sh
```

Use the method you prefer.

## Tearing Down the Student Clusters

***You should refresh your AWS credentials at this point, just in case.  Make sure you are in the the directory with all the class materials, where all the `studentX` directories reside!***

### Let's destroy the student clusters!

Run the `teardown_dka100.sh` script.  No arguments are necessary.  The script will count the number of student directories and will handle the process.  Again, ***make sure you are in the directory with the `studentX` directories in it!***
```
./dka100-instructor-tools/teardown_dka100.sh
```

When you are sure you no longer need the student directories, you can either remove all the student directories, or remove the directory with all the class materials, which contains the student directories.

## Using the DKA100 Instructor Tools - On Your Instructor Cluster

The DKA100 Instructor Tools contains scripts for deploying a DKP/Kommander environment in an automated fashion.  This can be handy if you need to catch up with students, have a student with a failed installation, etc.

The following scripts are provided:
- `instructor_dkp.sh` : this script is for automated deployment of the DKP environment
    - First argument: studentX
    - Second argument: ELB DNS
- `instructor_ebs.sh` : this script deploys the AWS EBS SCSI Provisioner
- `instructor_kommander.sh` : this script is for automated deployment of Kommander
- `instructor_all.sh` : this script does it all: DKP, EBS and Kommander
    - First argument: studentX
    - Second argument: ELB DNS

In order to use the scripts, clone them to your registry server.
```
git clone https://github.com/tdean-d2iq/dka100-instructor-tools.git
```
```
chmod 755 dka100-instructor-tools/*.sh
```

Run the scripts from the `centos` user's home directory.  For example, to deploy *everything*, from the `student1` environment, with a load balancer of `tf-lb-20210916224237772100000007-589772466.us-west-2.elb.amazonaws.com`, run:
```
./dka100-instructor-tools/instructor_all.sh student1 tf-lb-20210916224237772100000007-589772466.us-west-2.elb.amazonaws.com
```

The scripts are well-documented, so if you're curious, feel free to look "under the hood" to see what's going on or how they work.

### Enjoy, and good luck!
