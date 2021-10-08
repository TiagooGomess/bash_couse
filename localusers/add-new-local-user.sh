#!/bin/bash

# Checks if it has superuser privileges
if [[ "${UID}" -ne 0 ]]
then
	echo "You need superuser privileges to run this script."
	exit 1
fi

USERNAME="${1}"
shift
NAME="${*}"

echo "Username: ${USERNAME}"
echo "Name: ${NAME}"

# Creates a new user with the provided information
useradd -c "${NAME}" -m ${USERNAUSERNAMEE}

if [[ "${?}" -ne 0 ]]
then
	echo "An error occurred when creating the new user"
	exit 1
fi

# Sets the password to the new user
echo $PASSWORD | passwd --stdin ${USERNAME}

# Force the user to change the password on first login
passwd -e ${USERNAME}

echo "A new user was added:"
echo "Username: ${USERNAME}"
echo "Password: ${PASSWORD}"

HOST=$(hostname)

echo "Host: ${HOST}"
