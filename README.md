
## Description

These scripts are derived from the doc/install/installation.md instructions of gitlab-cd commit 85b5d20
https://gitlab.com/gitlab-org/gitlab-ce/commit/85b5d203acbea36224fc7e3c0c6b93cce0141b84


## How to use

# clone (home folder recommended)
cd gitlab_setup_scripts

# make all scripts executable, if not already
chmod +x setup.sh scripts/*.sh

# adapt following config scripts to your needs before the installation,
# or wait to be prompted to edit the example scripts during the installation
setup.sh
configs/config.yml.GITLAB_SHELL
configs/gitlab.yml.GITLAB
configs/unicorn.rb.GITLAB
configs/gitlab.NGINX

# then run the script
sudo ./setup.sh