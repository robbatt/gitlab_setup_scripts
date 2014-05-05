#!/bin/bash
set -e # stop on first error

echo
echo "########################################################"
echo "###### 3. Setup users                             ######"
echo "########################################################"
echo

if [ -z "$(getent passwd git)" ]; then
	sudo adduser --disabled-login --gecos 'GitLab' git
fi


