#!/bin/bash

# Make sure Git is version 1.7.10 or higher (we just use 1.8.5.2 or higher)


source lib_compare_version.sh

PROGNAME=$(basename $0)

if [[ -n "$GIT_TARGET_VERSION" ]] ; then
	GIT_TARGET_VERSION="1.8.5.2"
	echo "default git target version to $GIT_TARGET_VERSION"	
else
	echo "git target version is $GIT_TARGET_VERSION"
fi

# Check current git version
GIT_VERSION_FULL=`git --version` 
GIT_INSTALLED=$?

# check for expected output 'git version 1.8.5.2'
if [[ $GIT_INSTALLED == 0 ]] ; then

	if [[ ! "$GIT_VERSION_FULL" =~ "git version " ]]
	then
	    	echo "ERROR ${PROGNAME}: ${1:-'git --version' output has unexpected format}" 1>&2
	    	echo "ERROR ${PROGNAME}: ${1:-		got 	 \"$GIT_VERSION_FULL\"}" 1>&2
	    	echo "ERROR ${PROGNAME}: ${1:-		expected \"git version x.x.x.x\"}" 1>&2
		exit 1
	fi

	GIT_VERSION=${GIT_VERSION_FULL:12:10} # 'git version 1.8.5.2'
	#						     \     /
	echo "detected installed git version $GIT_VERSION"
	vercomp "1.8.5.2" $GIT_VERSION
	GIT_VERSION_COMPARE=$?
else 
	echo "no installed git detected"
fi

if [[ $GIT_VERSION_COMPARE == 0 ]] ; then
	echo "git $GIT_VERSION already installed [OK]"
else 
	echo "installing git $GIT_TARGET_VERSION from source [INFO]"

	# Remove packaged Git
	sudo apt-get purge -y git

	# Install dependencies
	sudo apt-get install -y libcurl4-openssl-dev libexpat1-dev gettext libz-dev libssl-dev build-essential

	# Download and compile git from source
	cd /tmp
	rm -rf git-$GIT_TARGET_VERSION*
	wget https://git-core.googlecode.com/files/git-$GIT_TARGET_VERSION.tar.gz
	tar xzf git-$GIT_TARGET_VERSION.tar.gz
	cd git-$GIT_TARGET_VERSION/
	make --silent prefix=/usr/local all

	# Install into /usr/local/bin
	sudo make --silent prefix=/usr/local install

	echo "git $GIT_TARGET_VERSION successfully installed"
fi

echo "`git --version`"
whereis git


