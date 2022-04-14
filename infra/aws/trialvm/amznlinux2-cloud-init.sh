#!/bin/bash
#set -e; [ "$TRACE" ] && set -x
set -e
set -x

# figure out the latest release
# This script must be run as root.
[ `id -u` != "0" ] && echo "Must run as root" && exit 1

source /etc/os-release
[ "$ID" != "fedora" -a "$ID" != "ubuntu" -a "$ID" != "amzn" ] && echo "Unsupported linux distribution: $ID" && exit 1

TAG=${1:-$(curl -L -s https://raw.githubusercontent.com/kontainapp/km/current/km-releases/current_release.txt)}
if [[ $TAG = latest ]] ; then
   readonly URL_KONTAIN_TAR_GZ="https://github.com/kontainapp/km/releases/${TAG}/download/kontain.tar.gz"
   readonly URL_KONTAIN_BIN="https://guide-assets.s3.us-west-2.amazonaws.com/downloads/kontain_bin.tar.gz"
else
   readonly URL_KONTAIN_TAR_GZ="https://github.com/kontainapp/km/releases/download/${TAG}/kontain.tar.gz"
   readonly URL_KONTAIN_BIN="https://guide-assets.s3.us-west-2.amazonaws.com/downloads/kontain_bin.tar.gz"
fi
readonly PREFIX="/opt/kontain"

# install yum-utils which contains needs-restarting to check if a reboot is necessary after update
yum install -y yum-utils wget jq git nmap-ncat.x86_64
# install kernel-devel for current package
yum install -y "kernel-devel-uname-r == $(uname -r)"
# update without updating kernel (IMPORTANT FOR KKM)
yum -y --exclude=kernel* update

# check if it needs rebooting while yum not running
# ensure that cloud-init runs again after reboot by removing the instance record created
(test ! -f /var/run/yum.pid && needs-restarting -r) || (rm -rf /var/lib/cloud/instances/;reboot)


#---------------
echo -----
echo "installing Kontain from ${URL_KONTAIN_BIN}"

# install Kontain with KKM
mkdir -p /tmp/kontain
cd /tmp/kontain
wget $URL_KONTAIN_BIN
tar xvzf kontain_bin.tar.gz

# move files into /opt/kontain
mkdir -p /opt/kontain/bin; chown root /opt/kontain
mv container-runtime/krun /opt/kontain/bin/krun
mv km/km /opt/kontain/bin/

# install KKM
./kkm.run


#---------------
# install docker
echo -----
echo "installing docker, compose"

amazon-linux-extras install -y docker

# start docker at the end
systemctl enable docker

# and include ec2-user in docker group
usermod -a -G docker ec2-user
# usermod -a -G docker ${USER}
# newgrp docker

# install docker-compose
wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)
mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
chmod -v +x /usr/local/bin/docker-compose

mkdir -p /etc/docker/
cat<<EOF >> /etc/docker/daemon.json
{
    "runtimes": {
        "krun": {
            "path": "/opt/kontain/bin/krun"
        }
    }
}
EOF

# start docker without blocking since cloud-init can cause deadlock issues
systemctl restart --no-block docker


# -----------------------------------
# install Kontain main release
curl -s https://raw.githubusercontent.com/kontainapp/km/current/km-releases/kontain-install.sh | sudo bash


#---------------
# installing nodejs
echo -----
echo "installing nodejs"
cd /tmp
sudo yum install -y gcc-c++ make
curl -sL https://rpm.nodesource.com/setup_12.x | sudo -E bash -
sudo yum install -y nodejs

# install golang
echo -----
echo "installing golang"
mkdir -p /home/ec2-user/go/src

# add golang path
cd /tmp
wget https://go.dev/dl/go1.17.7.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf /tmp/go1.17.7.linux-amd64.tar.gz

cat<<EOF >> /home/ec2-user/.bash_profile
export GOPATH='/home/feodra/go'
export GOROOT='/usr/local/go'
export PATH="$PATH:/usr/local/bin:/usr/local/go/bin"
EOF

##----------------
# install java
# installing JDK
# amazon-linux-extras install -y java-openjdk11

# install sdkman and java and maven
echo -----
echo "installing sdkman and java"
export SDKMAN_DIR="/usr/local/sdkman" && curl -s "https://get.sdkman.io" | bash

echo 'export SDKMAN_DIR="/usr/local/sdkman"' | tee -a /home/ec2-user/.bash_profile
echo 'source "/usr/local/sdkman/bin/sdkman-init.sh"' | tee -a /home/ec2-user/.bash_profile

# have to do this as the sdkman script has unbounded variable or something
set +u
source "/usr/local/sdkman/bin/sdkman-init.sh"
sdk install java 11.0.11.hs-adpt
sdk install maven
sdk install gradle
#----------------
echo -----
echo "installing kind, minikube, k3d"

#install minikube so we have kubernetes testing
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# install k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# install kind cluster
curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.8.1/kind-$(uname)-amd64
chmod +x /usr/local/bin/kind

#----------------
# install nginx
amazon-linux-extras install nginx1 -y
echo "<h1>$(curl https://api.kanye.rest/?format=text)</h1>" >  /usr/share/nginx/html/index.html 
systemctl enable nginx
systemctl start nginx

#-----
echo -----
echo "Finished Initializing VM!!"
