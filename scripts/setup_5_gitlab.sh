#!/bin/bash
set -e # stop on first error

echo
echo "########################################################"
echo "###### 5. GitLab                                  ######"
echo "########################################################"
echo

if [[ ! -n $GITLAB_BRANCH ]] ; then
	$GITLAB_BRANCH="6-8-stable"
	echo "default gitlab branch to $GITLAB_BRANCH"	
else
	echo "gitlab branch $GITLAB_BRANCH used"
fi

# We'll install GitLab into home directory of the user "git"
cd /home/git

# Clone GitLab repository
if [[ -e "gitlab" ]] ; then
	echo "gitlab already cloned, wiping changes, reseting to HEAD,"
	echo "checking out latest commit of branch $GITLAB_BRANCH"
	cd gitlab
	sudo -u git -H git reset --hard HEAD
	sudo -u git -H git pull
	sudo -u git -H git checkout $GITLAB_BRANCH
else
	sudo -u git -H git clone https://gitlab.com/gitlab-org/gitlab-ce.git -b $GITLAB_BRANCH gitlab
fi

# Go to gitlab dir
cd /home/git/gitlab


### CONFIGURATION 

# Copy the GitLab config
if [[ -n $GITLAB_CONFIG_YML_FILE ]] ; then
	echo "copying settings file $GITLAB_CONFIG_YML_FILE to gitlab/config/gitlab.yml"
	sudo -u git -H cp $GITLAB_CONFIG_YML_FILE config/gitlab.yml
	sudo -u git -H chown git:git config/gitlab.yml
else
	sudo -u git -H cp config/gitlab.yml.example config/gitlab.yml
	
	echo "# Make sure to change \"localhost\" to the"
	echo "# fully-qualified domain name of your host"
	echo "# serving GitLab where necessary"
	echo "#"
	echo "# change the git bin_path to /usr/local/bin/git"
	echo "#"
	echo "### press [Enter] to continue"
	read dummy
	sudo -u git -H editor config/gitlab.yml # do not spawn as separate process, we want the rest of the script to wait
fi

# Make sure GitLab can write to the log/ and tmp/ directories
sudo chown -R git log/
sudo chown -R git tmp/
sudo chmod -R u+rwX log/
sudo chmod -R u+rwX tmp/

# Create directory for repositories
sudo -u git -H mkdir -p /home/git/repositories

# Create directory for satellites
sudo -u git -H mkdir -p /home/git/gitlab-satellites
sudo chmod u+rwx,g+rx,o-rwx /home/git/gitlab-satellites

# Make sure GitLab can write to the tmp/pids/ and tmp/sockets/ directories
sudo chmod -R u+rwX tmp/pids/
sudo chmod -R u+rwX tmp/sockets/

# Make sure GitLab can write to the public/uploads/ directory
sudo chmod -R u+rwX  public/uploads

# Copy the unicorn config
if [[ -n $GITLAB_UNICORN_RB_FILE ]] ; then
	echo "copying settings file $GITLAB_UNICORN_RB_FILE to gitlab/config/unicorn.rb"
	sudo -u git -H cp $GITLAB_UNICORN_RB_FILE config/unicorn.rb
	sudo -u git -H chown git:git config/unicorn.rb
else
	sudo -u git -H cp config/unicorn.rb.example config/unicorn.rb
	
	echo "# Enable cluster mode if you expect to have a high load instance"
	echo "# Ex. change amount of workers to 3 for 2GB RAM server"
	echo "#"
	echo "# change the git bin_path to /usr/local/bin/git"
	echo "#"
	echo "### press [Enter] to continue"
	read dummy
	sudo -u git -H editor config/unicorn.rb # do not spawn as separate process, we want the rest of the script to wait
fi

# Copy the example Rack attack config
### TODO change this if you need anything else than defaults
sudo -u git -H cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb

# Configure Git global settings for git user, useful when editing via web
# Edit user.email according to what is set in gitlab.yml
sudo -u git -H git config --global user.name "GitLab"
sudo -u git -H git config --global user.email "gitlab@localhost"
sudo -u git -H git config --global core.autocrlf input


##### Configure GitLab DB settings

# MySQL only:
sudo -u git cp config/database.yml.mysql config/database.yml

# Copy the MySQL config
if [[ -n $GITLAB_DATABASE_YML_FILE ]] ; then
	echo "copying settings file $GITLAB_DATABASE_YML_FILE to gitlab/config/database.yml"
	sudo -u git -H cp $GITLAB_DATABASE_YML_FILE config/database.yml
	sudo -u git -H chown git:git config/database.yml
else
	sudo -u git -H cp config/database.yml.mysql config/database.yml
	
	echo "# Update username/password in config/database.yml."
	echo "# You only need to adapt the production settings (first part)."
	echo "#"
	echo "# And change 'secure password' with the value you have given to $password"
	echo "# You can keep the double quotes around the password"
	echo "#"
	echo "### press [Enter] to continue"
	read dummy
	sudo -u git -H editor config/database.yml # do not spawn as separate process, we want the rest of the script to wait
fi

# PostgreSQL and MySQL:
# Make config/database.yml readable to git only
sudo -u git -H chmod o-rwx config/database.yml



######## Install Gems

cd /home/git/gitlab

# Or if you use MySQL (note, the option says "without ... postgres")
sudo -u git -H bundle install --deployment --without development test postgres aws

######### Initialize Database and Activate Advanced Features

cd /home/git/gitlab

yes yes | sudo -u git -H bundle exec rake gitlab:setup RAILS_ENV=production
echo 

# Type 'yes' to create the database tables.

# When done you see 'Administrator account created:'


######### Install Gitlab Shell

if [[ -n $GITLAB_SHELL_TARGET_VERSION ]] ; then
	GITLAB_SHELL_TARGET_VERSION="1.9.3"
	echo "default gitlab shell target version to $GITLAB_SHELL_TARGET_VERSION"	
else
	echo "gitlab shell target version is $GITLAB_SHELL_TARGET_VERSION"
fi

# Go to home directory
cd /home/git

# Remove previous installation
sudo rm -rf gitlab-shell

# Go to the Gitlab installation folder:
cd /home/git/gitlab

# Run the installation task for gitlab-shell (replace `REDIS_URL` if needed):
sudo -u git -H bundle exec rake gitlab:shell:install[$GITLAB_SHELL_TARGET_VERSION] REDIS_URL=redis://localhost:6379 RAILS_ENV=production

# Copy configs to gitlab-shell folder
cd /home/git/gitlab-shell
if [[ -n $GITLAB_SHELL_CONFIG_YML_FILE ]] ; then
	echo "copying settings file $GITLAB_SHELL_CONFIG_YML_FILE to gitlab-shell/config.yml"
	sudo -u git -H cp $GITLAB_SHELL_CONFIG_YML_FILE config.yml
else
	sudo -u git -H cp config.yml.example config.yml
	
	echo "### Edit gitlab-shell config and replace gitlab_url"
	echo "### with something like 'http://domain.com/'"
	echo "### this will be the web address to reach your gitlab instance"
	echo "### press [Enter] to continue"
	read dummy
	sudo -u git -H editor config.yml # do not spawn as separate process, we want the rest of the script to wait
fi



######### Install Init Script

cd /home/git/gitlab
sudo cp lib/support/init.d/gitlab /etc/init.d/gitlab

sudo update-rc.d gitlab defaults 21


######### Set up logrotate

sudo cp lib/support/logrotate/gitlab /etc/logrotate.d/gitlab

######### Check Application Status

sudo -u git -H bundle exec rake gitlab:env:info RAILS_ENV=production


######### Compile assets

sudo -u git -H bundle exec rake assets:precompile RAILS_ENV=production


########## Start Your GitLab Instance

sudo service gitlab start


######### Compile assets again?

sudo -u git -H bundle exec rake assets:precompile RAILS_ENV=production


