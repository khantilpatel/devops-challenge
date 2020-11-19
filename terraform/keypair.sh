#!/usr/bin/env bash

FILE=~/.ssh/app-key

if [[ ! -f ${FILE}.pem ]]; then
    echo "Generating keys"
    ssh-keygen -t rsa -b 2048 -f ${FILE}.pem -q -P ''
    chmod 400 ${FILE}.pem
    ssh-keygen -y -f ${FILE}.pem > ${FILE}.pub
    exit
fi

echo "Keys already exists!"
