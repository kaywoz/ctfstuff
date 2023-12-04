#!/bin/bash

# List all users excluding 'root' and 'jking'
for user in $(awk -F: '{if ($3 >= 1000 && $1 != "useraccount1" && $1 != "useraccount2") print $1}' /etc/passwd); do
    echo "Deleting user and home directory: $user"
    sudo userdel -r $user
done