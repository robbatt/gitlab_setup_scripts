#!/bin/bash
set -e # stop on first error

echo
echo "########################################################"
echo "###### 2. Setup ruby snapshot                     ######"
echo "########################################################"
echo


if [[ -n $RUBY_TARGET_REVISION ]] ; then
	$RUBY_TARGET_REVISION="r45816"
	echo "default ruby target revision to $RUBY_TARGET_REVISION"	
else
	echo "ruby target revision is $RUBY_TARGET_REVISION"
fi

echo "installing ruby revision $RUBY_TARGET_REVISION from source [INFO]"

# Download (again) ruby sources
cd /tmp
if [[ ! -e /tmp/trunk ]] ; then 
	echo "downloading sources"
	sudo apt-get install -y subversion
	svn co http://svn.ruby-lang.org/repos/ruby/trunk@$RUBY_TARGET_REVISION
fi

# Build and install Ruby
if [[  ! -e /tmp/ruby_build ]] || [[ ! -e /tmp/ruby_build/build_successful ]] ; then 

	# Remove packaged ruby
	sudo apt-get purge -y ruby1.*
	sudo apt-get purge -y ruby2.*
	sudo apt-get install -y autoconf

	cd trunk
	autoconf
	mkdir -p /tmp/ruby_build
	cd /tmp/ruby_build
	rm -rf *
	./tmp/trunk/configure --disable-install-rdoc
	make
	sudo make install
	if [[ $? == 0 ]] ; then 
		sudo touch /tmp/trunk/build_successful
	fi
fi

echo "ruby revision $RUBY_TARGET_REVISION successfully installed"
sudo gem install bundler --no-ri --no-rdoc

echo "`ruby --version`"
whereis ruby

