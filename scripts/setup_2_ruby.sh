#!/bin/bash
set -e # stop on first error

source lib_compare_version.sh

echo
echo "########################################################"
echo "###### 2. Setup ruby                              ######"
echo "########################################################"
echo

RUBY_MIN_VERSION="2.1.1"

if [[ -n $RUBY_TARGET_VERSION ]] ; then
	echo "ruby target version is $RUBY_TARGET_VERSION"
else
	RUBY_TARGET_VERSION=$RUBY_MIN_VERSION
	echo "default ruby target version to $RUBY_TARGET_VERSION"	
fi

RUBY_TARGET_VERSION_MAJOR_MINOR=${RUBY_TARGET_VERSION:0:3}

# Check current ruby version
whereis_out=`whereis ruby`
while read -r line ; do
	if [[ "$line" =~ "bin" ]] ; then
		RUBY_INSTALLED=0
		RUBY_VERSION_FULL=`ruby --version` 
	fi
done <<< $whereis_out




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
	vercomp $RUBY_MIN_VERSION $RUBY_VERSION
	RUBY_VERSION_COMPARE=$?
else 
	echo "no installed ruby detected"
fi

if [[ $RUBY_VERSION_COMPARE == 0 ]] || [[ $RUBY_VERSION_COMPARE == 1 ]] ; then
	echo "ruby installed $RUBY_VERSION >= required $RUBY_MIN_VERSION [OK]"
else
	echo "installing ruby $RUBY_TARGET_VERSION from source [INFO]"

	# Download (again) ruby sources
	cd /tmp
	if [[ ! -e /tmp/ruby-$RUBY_TARGET_VERSION.tar.gz ]] ; then 
		echo "downloading sources"
		wget "ftp://ftp.ruby-lang.org/pub/ruby/$RUBY_TARGET_VERSION_MAJOR_MINOR/ruby-$RUBY_TARGET_VERSION.tar.gz"
	fi

	# Unzip archive
	if [[ ! -e /tmp/ruby-$RUBY_TARGET_VERSION ]] ; then 
		echo "unpacking source archive"
		rm -rf /tmp/ruby-$RUBY_TARGET_VERSION
		tar xzf ruby-$RUBY_TARGET_VERSION.tar.gz
	fi

	# Build and install Ruby
	if [[ ! -e /tmp/ruby-$RUBY_TARGET_VERSION-build/ ]] || [[ ! -e /tmp/ruby-$RUBY_TARGET_VERSION-build/build_successful ]] ; then 

		sudo apt-get install -y ruby

		mkdir -p /tmp/ruby-$RUBY_TARGET_VERSION
		cd /tmp/ruby-$RUBY_TARGET_VERSION

		/tmp/ruby-$RUBY_TARGET_VERSION/configure --disable-install-rdoc
		
		make --silent
		sudo make --silent install
		if [[ $? == 0 ]] ; then 
			sudo touch /tmp/ruby-$RUBY_TARGET_VERSION/build_successful

			# Remove packaged ruby
			sudo apt-get purge -y ruby1.*
			sudo apt-get purge -y ruby2.*
		fi
	fi

	echo "ruby $RUBY_TARGET_VERSION successfully installed"
	sudo gem install bundler --no-ri --no-rdoc

fi

echo "`ruby --version`"
whereis ruby


