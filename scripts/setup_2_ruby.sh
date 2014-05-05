#!/bin/bash

source lib_compare_version.sh

echo
echo "########################################################"
echo "###### 2. Setup ruby                              ######"
echo "########################################################"
echo


if [[ ! -n $RUBY_TARGET_VERSION ]] ; then
	RUBY_TARGET_VERSION="2.1.1"
	echo "default ruby target version to $RUBY_TARGET_VERSION"	
else
	echo "ruby target version is $RUBY_TARGET_VERSION"
fi

RUBY_TARGET_VERSION_MAJOR_MINOR=${RUBY_TARGET_VERSION:0:3}


# Check current ruby version
RUBY_VERSION_FULL=`ruby --version` 
RUBY_INSTALLED=$?

# check for expected output 'ruby 2.1.1 (2014-02-24 revision 45167) [x86_64-linux]'
if [[ $RUBY_INSTALLED == 0 ]] ; then

	if [[ ! "$RUBY_VERSION_FULL" =~ "ruby " ]]
	then
	    	echo "ERROR ${PROGNAME}: ${1:-'ruby --version' output has unexpected format}" 1>&2
	    	echo "ERROR ${PROGNAME}: ${1:-		got 	 \"$RUBY_VERSION_FULL\"}" 1>&2
	    	echo "ERROR ${PROGNAME}: ${1:-		expected \"ruby x.x.x....\"}" 1>&2
		exit 1
	fi

	RUBY_VERSION=${RUBY_VERSION_FULL:5:5} # 'ruby 2.1.1p76 (2014-02-24 revision 45161) [x86_64-linux]'
	#					      \   /
	echo "detected installed ruby version $RUBY_VERSION"
	vercomp "2.1.1" $RUBY_VERSION
	RUBY_VERSION_COMPARE=$?
else 
	echo "no installed ruby detected"
fi

if [[ $RUBY_VERSION_COMPARE == 0 ]] || [[ $RUBY_VERSION_COMPARE == 1 ]] ; then
	echo "ruby installed $RUBY_VERSION >= required 2.1.1 [OK]"
else
	echo "installing ruby $RUBY_TARGET_VERSION from source [INFO]"

	# Remove packaged ruby
	sudo apt-get purge -y ruby1.*
	sudo apt-get purge -y ruby2.*

	rm -rf /tmp/ruby-$RUBY_TARGET_VERSION*
	cd /tmp
	wget "ftp://ftp.ruby-lang.org/pub/ruby/$RUBY_TARGET_VERSION_MAJOR_MINOR/ruby-$RUBY_TARGET_VERSION.tar.gz"
	tar xzf ruby-$RUBY_TARGET_VERSION.tar.gz
	cd ruby-$RUBY_TARGET_VERSION
	./configure --disable-install-rdoc
	make
	sudo make install

	echo "ruby $RUBY_TARGET_VERSION successfully installed"
	sudo gem install bundler --no-ri --no-rdoc

fi

echo "`ruby --version`"
whereis ruby


