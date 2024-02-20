#!/bin/bash

service postfix start
service dovecot start

tail -f /dev/null