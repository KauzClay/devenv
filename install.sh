#!/bin/bash

GO_VERSION=1.17.6

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root"
    exit
fi

export DEBIAN_FRONTEND=noninteractive

workspace_path=/home/daisy/workspace

apt-get update
apt-get install -yq apt-utils
apt-get update
apt-get install -yq \
  apt-transport-https \
  aria2 \
  asciidoc \
  autoconf \
  autoconf \
  automake \
  awscli \
  bash-completion \
  bison \
  build-essential \
  curl \
  direnv \
  docker.io \
  fasd \
  fd-find \
  git \
  gpg \
  jq \
  libffi-dev \
  libgdbm-dev \
  libncurses5-dev \
  libreadline-dev \
  libssl-dev \
  libyaml-dev \
  lsb-release \
  mosh \
  npm \
  openconnect \
  python3-pip \
  ripgrep \
  silversearcher-ag \
  software-properties-common \
  shellcheck \
  tmux \
  tree \
  wget \
  xclip \
  zlib1g-dev \

sudo ln -s $(which fdfind) /usr/bin/fd

# install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# gcloud
sudo apt-get install -yq apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install -yq google-cloud-sdk
gcloud init

# install golang the right way
mkdir -p /tmp/installscratch
cd /tmp/installscratch
wget https://dl.google.com/go/go"${GO_VERSION}".linux-amd64.tar.gz
tar -xvf go*
rm -rf /usr/local/go
mv go /usr/local
rm -rf /tmp/installscratch

# install user specific programs as pivotal
sudo -u daisy /home/daisy/workspace/devenv/install-as-daisy.sh

# neovim
sudo snap install nvim --classic

# k9s
mkdir -p /tmp/k9s
pushd /tmp/k9s
url=$(curl -s https://api.github.com/repos/derailed/k9s/releases | jq -r '.[0].assets[] | select(.name | contains("Linux_x86_64")).browser_download_url')
  wget -O k9s.tar.gz "$url"
  tar -xvf k9s.tar.gz
  chmod +x k9s
  mv k9s /usr/local/bin/
popd

# kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv kubectl /usr/local/bin/kubectl

## krew for kubectl
set -x; cd "$(mktemp -d)" &&
OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
KREW="krew-${OS}_${ARCH}" &&
curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
tar zxvf "${KREW}.tar.gz" &&
./"${KREW}" install krew

# install kubectl plugins
kubectl krew install ctx
kubectl krew install ns
kubectl krew install tree

# pip3 things
pip3 install yq neovim when-changed

# Carvel tools
curl -L https://carvel.dev/install.sh | bash

# yq
VERSION=v4.18.1
BINARY=yq_linux_amd64
wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz -O - |\
  tar xz && mv ${BINARY} /usr/bin/yq

# certstrap
mkdir -p /tmp/certstrap
pushd /tmp/certstrap
  url=$(curl -s https://api.github.com/repos/square/certstrap/releases | jq -r '.[0].assets[] | select((.name | contains("linux"))).browser_download_url')
  curl -L "${url}" --output certstrap
  sudo install certstrap /usr/local/bin/certstrap
popd

# ctlptl
mkdir -p /tmp/ctlptl
pushd /tmp/ctlptl
  ctlptl_version="0.4.1"
  url="https://github.com/tilt-dev/ctlptl/releases/download/v${ctlptl_version}/ctlptl.${ctlptl_version}.linux.x86_64.tar.gz"
  curl -L "${url}" | tar -zx
  sudo mv ctlptl /usr/local/bin/ctltptl
popd

# tilt
curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash
# avoid conflicts with tilt ruby package
sudo mv /usr/local/bin/tilt /usr/local/bin/tlt


# Overwrite /etc/resolv.conf
# This is necessary because openconnect will want to overwrite the file when it
# is connected to a vpn, which doesn't play nicely with systemd-resolved
# because systemd-resolved can potentially overwrite the changes by openconnect
# at any time without openconnect knowing. It is therefore, easier to only have
# a single process attempt to change /etc/resolv.conf at any time.

rm -f /etc/resolv.conf
cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

# downloaded from https://drive.google.com/a/pivotal.io/file/d/1GxaJGgvoTapDjdq1J3qCkxRBAztIbtOQ/view?usp=sharing
# also, see instructions at:
# https://sites.google.com/a/pivotal.io/pivotal-it/office-equipment/networking/pivotal-vpn/global-protect#TOC-Linux-Installation
dpkg -i "$workspace_path/vpn/GlobalProtect_deb-5.1.0.0-101.deb"
