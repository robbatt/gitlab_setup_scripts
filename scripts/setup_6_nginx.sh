#!/bin/bash
set -e # stop on first error

echo
echo "########################################################"
echo "###### 6. Nginx                                   ######"
echo "########################################################"
echo

sudo apt-get install -y nginx



# Copy the GitLab config
if [[ -n $NGINX_SITE_AVAILABLE_FILE ]] ; then
	echo "copying settings file $NGINX_SITE_AVAILABLE_FILE to /etc/nginx/sites-available/gitlab"
	sudo -u git -H cp $NGINX_SITE_AVAILABLE_FILE /etc/nginx/sites-available/gitlab
	sudo -u git -H chown root:root /etc/nginx/sites-available/gitlab
else
	sudo cp /home/git/gitlab/lib/support/nginx/gitlab /etc/nginx/sites-available/gitlab
	
	echo "# Change YOUR_SERVER_FQDN to the fully-qualified"
	echo "# domain name of your host serving GitLab"
	echo "#"
	echo "### press [Enter] to continue"
	read dummy
	sudo editor /etc/nginx/sites-available/gitlab # do not spawn as separate process, we want the rest of the script to wait
fi

# enable the site
sudo ln -s /etc/nginx/sites-available/gitlab /etc/nginx/sites-enabled/gitlab

# disable the nginx default site
sudo rm /etc/nginx/sites-enabled/default

sudo service nginx restart

