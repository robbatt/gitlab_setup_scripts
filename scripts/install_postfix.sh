#!/bin/bash

# preset postfix config
if [[ ! -n "$POSTFIX_MAILNAME" ]] && [[ ! -n "$POSTFIX_MAILERTYPE" ]] ; then
	sudo debconf-set-selections <<< "postfix postfix/mailname string $POSTFIX_MAILNAME"
	sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string $POSTFIX_MAILERTYPE"
fi

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y postfix

