#!/bin/bash

IFS=',' read -r -a friends_array <<< "$FRIENDS"
for friend in "${friends_array[@]}"
do
    echo "$friend" >> /etc/postfix/transport
done

sed -i "s/^myhostname = .*/myhostname = ${MY_HOSTNAME}/" /etc/postfix/main.cf
echo "${MY_HOSTNAME} :" >> /etc/postfix/transport

touch /var/log/dovecot.log /var/log/dovecot-info.log /var/log/dovecot-debug.log
chown dovecot:dovecot /var/log/dovecot*.log
chmod 0644 /var/log/dovecot*.log

postmap /etc/postfix/transport