#!/bin/bash

# preset postfix config
if [[ -z "$POSTFIX_MAILNAME" ]] && [[ -z "$POSTFIX_MAILERTYPE" ]] ; then
	sudo debconf-set-selections <<< "postfix postfix/mailname string $POSTFIX_MAILNAME"
	sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string $POSTFIX_MAILERTYPE"
	
	sudo DEBIAN_FRONTEND=noninteractive apt-get install -y postfix
	
	else
	
	sudo apt-get install -y postfix
fi


