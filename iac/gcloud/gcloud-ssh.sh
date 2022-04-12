if (($# < 1))
then 
  echo "please pass in the name of the VM"
  exit 0
fi

NAME=$1
gcloud compute ssh ${NAME}
