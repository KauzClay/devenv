#!/bin/bash

mkdir -p workspace
cd workspace
echo "Cloning the devenv scripts"
git clone https://github.com/KauzClay/devenv.git

cd devenv
echo "Installing required packages and tools, you may be prompted for your sudo password."
sudo ./install.sh
./configure.sh
./gitconfig.sh
cd ~
echo "All done! Disconnect and log back in to ensure you have everything."

echo "Our repositories can't be cloned without access to the VPN. Connect to the VPN with 'globalprotect connect --portal gpu.vmware.com -u ${username}', then run ./workspace/devenv/cloner.sh to get the rest."
