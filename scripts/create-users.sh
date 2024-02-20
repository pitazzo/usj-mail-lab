#!/bin/bash

IFS=',' read -r -a users_array <<< "$USERS"

for user_pair in "${users_array[@]}"
do
    IFS=':' read -r user password <<< "$user_pair"
    useradd -m "$user" -s /bin/bash && echo "$user:$password" | chpasswd
done
