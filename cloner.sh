#!/bin/bash

if [[ $(/usr/bin/id -u) -eq 0 ]]; then
    echo "Don't run me as root"
    exit
fi

clone_if_not_exist() {
  local remote=$1
  local dst_dir="$2"
  echo "Cloning $remote into $dst_dir"
  if [[ ! -d $dst_dir ]]; then
    git clone "$remote" "$dst_dir"
  fi
}

mkdir -p ~/workspace
mkdir -p ~/go

echo "Cloning all of the repos we work on..."

# tanzu-serverless
clone_if_not_exist "git@gitlab.eng.vmware.com:daisy/tanzu-serverless.git" "${HOME}/workspace/daisy/tanzu-serverless"
pushd "${HOME}/workspace/daisy/tanzu-serverless"
git submodules update --init --recursive
popd
# docs
clone_if_not_exist
"git@gitlab.eng.vmware.com:daisy/cloud-native-runtimes-for-vmware-tanzu.git" "${HOME}/workspace/daisy/cnr-docs"
# environments
clone_if_not_exist "git@gitlab.eng.vmware.com:daisy/environments.git" "${HOME}/workspace/daisy/environments"
# telemetry
clone_if_not_exist "git@gitlab.eng.vmware.com:daisy/tap-telemetry.git" "${HOME}/workspace/daisy/tap-telemetry"

# base16-shell: For the porple
clone_if_not_exist "https://github.com/chriskempson/base16-shell" "${HOME}/.config/base16-shell"

# Norsk Config -- for OSL
clone_if_not_exist "git@github.com:pivotal-cf/norsk-config" "${HOME}/workspace/norsk-config"

# Norsk repo for running OSL pipeline tasks locally
clone_if_not_exist "git@github.com:pivotal-cf/norsk.git" "${HOME}/workspace/norsk"

# Unpack utility for recursive untar/unzip. Useful for log files from support
clone_if_not_exist "git@github.com:stephendotcarter/unpack.git" "${HOME}/workspace/unpack"

# Note: requires VPN access
# Install GlobalProtect (automated in install.sh)
#
# Connect to VPN
# 1. globalprotect connect --portal portal-nasa.vpn.pivotal.io -u ${username}
# 2. Choose 1 (Okta verify)
