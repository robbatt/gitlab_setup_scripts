#!/bin/bash
set -e # stop on first error

echo
echo "########################################################"
echo "###### 1. Setup dependencies                      ######"
echo "########################################################"
echo

sudo apt-get update
sudo apt-get upgrade

sudo apt-get install -y build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev logrotate

# Install Git
bash install_git.sh

# When editing config/gitlab.yml (Step 6), change the git bin_path to /usr/local/bin/git

# Install Postfix
bash install_postfix.sh

