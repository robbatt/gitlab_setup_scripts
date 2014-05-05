#!/bin/bash
set -e # stop on first error

echo
echo "########################################################"
echo "###### Gitlab install script                      ######"
echo "########################################################"
echo
echo "### developed for https://gitlab.com/gitlab-org/gitlab-ce/commit/85b5d203acbea36224fc7e3c0c6b93cce0141b84 ###"
echo

# SETTINGS
export BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Step 1
export GIT_TARGET_VERSION="1.8.5.2"

export POSTFIX_MAILNAME="my.domain"
export POSTFIX_MAILERTYPE="'Internet Site'"

# Step 2
export RUBY_TARGET_VERSION="2.1.1"
#export RUBY_TARGET_VERSION="2.0.0-p451"

# Step 4
export GITLAB_DB_PASS="myPass"
export GITLAB_DB_ROOT_PASS="myRootPass"

# Step 5
export GITLAB_BRANCH="master"

export GITLAB_SHELL_TARGET_VERSION="1.9.3"
export GITLAB_SHELL_CONFIG_FILE="$BASEDIR/configs/config.yml.GITLAB_SHELL"

export GITLAB_CONFIG_YML_FILE="$BASEDIR/configs/gitlab.yml.GITLAB"
export GITLAB_UNICORN_RB_FILE="$BASEDIR/configs/unicorn.rb.GITLAB"
export GITLAB_DATABASE_YML_FILE="$BASEDIR/configs/database.yml.GITLAB"

# Step 6
export NGINX_SITE_AVAILABLE_FILE="$BASEDIR/configs/gitlab.NGINX"

# USER WARNING
echo
echo "This script is radical, read this before continueing !!!"
echo " - it WIPES ALL gitlab, git and ruby installations from the machine, no more asking"
echo " - it installs git $GIT_TARGET_VERSION (unless 1.8.5.2 or bigger is installed)"
echo " - it installs ruby $RUBY_TARGET_VERSION"
echo " - it installs gitlab branch $GITLAB_BRANCH"
echo 
echo "hit (w) to wipe everything and do a fresh install"
#echo "hit (b) to run a backup before"

if [[ ! -n $1 ]] ; then
	
	read permission

	if [[ ! "$permission" =~ "w" ]] ; then
		echo "ABORTED BY USER"
		exit 1
	fi
fi

# SETUP
cd $BASEDIR/scripts && bash setup_1_dependencies.sh
cd $BASEDIR/scripts && bash setup_2_ruby.sh
cd $BASEDIR/scripts && bash setup_3_users.sh
cd $BASEDIR/scripts && bash setup_4_database.sh
cd $BASEDIR/scripts && bash setup_5_gitlab.sh
cd $BASEDIR/scripts && bash setup_6_nginx.sh

echo
echo "setup script successful"
echo "navigate to localhost"
echo
echo "user: admin"
echo "pass: 5iveL!fe"
echo
echo "have fun!"


