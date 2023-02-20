#!/bin/bash

source $(dirname ${0})/lib.sh

cat > sources.list << EOF
deb-src http://archive.ubuntu.com/ubuntu focal main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu focal-updates main restricted universe multiverse
deb-src http://security.ubuntu.com/ubuntu focal-security main restricted universe multiverse
EOF
sudo mv sources.list /etc/apt/sources.list.d/

sudo apt-get -y update
