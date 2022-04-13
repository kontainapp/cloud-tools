SHELL :=/bin/bash

create: create-vm add-ssh list-vms
.PHONY: create

# exports all vars
.EXPORT_ALL_VARIABLES:

# used when wanting to rsync (. hidden) files
#SHELL := bash -O dotglob or extglob
SHELL := /bin/bash

configure:
	az config set defaults.location=westus2 defaults.group=demos

create-resource-group:
	az group create --name demos --location westus2

create-vm:
# if (($# < 1))
# then 
#   echo "please pass in the name of the VM"
#   exit 0
# fi
	az vm create \
	--resource-group demos \
	--name demovm1 \
	--image UbuntuLTS \
	--admin-username azureuser \
	--size Standard_D4s_v3 \
	--public-ip-sku Standard \
	--ssh-key-values ~/.ssh/id_rsa.pub
	# smallest - Standard_D2_v3

delete-vm:
	export NAME=demovm1
	az vm delete --name demovm1

list-vms:
	az vm list --output table
	az vm list-ip-addresses -o table

list-zone-cpu-families:
	az vm list-sizes --location westus -o table

add-ssh:

ssh:
	# gcloud compute ssh demovm1
	ssh azureuser@<public-ip>