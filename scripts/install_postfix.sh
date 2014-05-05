#!/bin/bash

# preset postfix config
if [[ -z "$POSTFIX_MAILNAME" ]] && [[ -z "$POSTFIX_MAILERTYPE" ]] ; then
	sudo debconf-set-selections <<< "postfix postfix/mailname string $POSTFIX_MAILNAME"
	sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string $POSTFIX_MAILERTYPE"
fi

sudo apt-get install -y postfix

