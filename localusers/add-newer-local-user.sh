#!/bin/bash

# Checks if it has superuser privileges
if [[ "${UID}" -ne 0 ]]
then
	echo "You need superuser privileges to run this script." >&2
	exit 1
fi

if [[ "${#}" -lt 1 ]]
then
	echo "Usage: ${0} USERNAME [NAME]..." >&2
	echo "Create an account on the local system with the user name of USERNAME and a name of NAME." >&2
	exit 1
fi

USERNAME="${1}"
shift
NAME="${*}"

# Creates a new user with the provided information
useradd -c "${NAME}" -m ${USERNAME} &> /dev/null

if [[ "${?}" -ne 0 ]]
then
	echo "An error occurred when creating the new user" >&2
	exit 1
fi

SPECIAL_CHARACTER=$(echo '!@#$%^&*()_-+=' | fold -w1 | shuf | head -c1)

PASSWORD=$(date +%s%N${RANDOM}${RANDOM} | sha256sum | head -c48)$SPECIAL_CHARACTER

# Sets the password to the new user
echo $PASSWORD | passwd --stdin ${USERNAME} &> /dev/null

# Force the user to change the password on first login
passwd -e ${USERNAME} &> /dev/null

echo "Username: ${USERNAME}"
echo "Password: ${PASSWORD}"

HOST=$(hostname)

echo "Host: ${HOST}"
