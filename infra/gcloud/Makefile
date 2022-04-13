SHELL :=/bin/bash

create: create-vm add-ssh list-vms
.PHONY: create

# exports all vars
.EXPORT_ALL_VARIABLES:

# used when wanting to rsync (. hidden) files
#SHELL := bash -O dotglob or extglob
SHELL := /bin/bash

#------------------------------------------------
#-------- list codebuild role names
#------------------------------------------------
create-vm:
# if (($# < 1))
# then 
#   echo "please pass in the name of the VM"
#   exit 0
# fi
	export NAME=demovm1
	# e2-standard-2 cannot be nested virtualization enabled, min is n2-standard-2(haswell cpu)
	#	--machine-type=n2-standard-2 \
	gcloud compute instances create demovm1 \
		--image-family=ubuntu-2110 \
		--image-project=ubuntu-os-cloud \
		--enable-nested-virtualization \
		--min-cpu-platform="Intel Haswell"

delete-vm:
	export NAME=demovm1
	echo y | gcloud compute instances delete demovm1

list-vms:
	gcloud compute instances list

list-zone-cpu-families:
	gcloud compute zones describe us-central1-a

add-ssh:
	export NAME=demovm1
	gcloud compute config-ssh --ssh-key-file=~/.ssh/id_rsa
	# wait 10 seconds
	sleep 10

ssh:
	# gcloud compute ssh demovm1
	ssh demovm1.us-central1-c.gke-suport