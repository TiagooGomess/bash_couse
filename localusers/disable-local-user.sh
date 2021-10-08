#!/bin/bash

# Display the usage and exit.
usage() {
	echo "Usage: ${0} [-dra] [username].." >&2
	echo "Disable a user." >&2
	echo "	-d			Deletes accounts instead of disabling them." >&2
	echo "	-r			Removes the home directory associated with the accounts." >&2
	echo "	-a			Creates an archive of the home directory associated with the deleted accounts and stores the archive in the /archives directory." >&2
	echo "	username..	Usernames of the users to delete." >&2
	exit 1
}

# Make sure the script is being executed with superuser privileges.
if [[ "${UID}" -ne 0 ]]
then
	echo "You need root privileges to execute this script." >&2
	exit 1
fi

# Parse the options.
while getopts dra OPTION
do
	case ${OPTION} in
		d)
			DELETE_ACCOUNTS='true'
			;;
		r)
			REMOVE_HOME_DIRECTORY='true'
			;;
		a)
			ARCHIVE_HOME_DIRECTORY='true'
			;;
		?)
			usage
			;;
	esac
done

# Remove the options while leaving the remaining arguments.
shift "$(( OPTIND - 1 ))"

# Give the user help if they don't supply at least one argument.
if [[ "${#}" -eq 0 ]]
then
	echo 'You need to provide at least one username.' >&2
	usage
fi

ARCHIVE_DIR='/archives'

# Loop through all the usernames supplied as arguments.
while [[ "${#}" -gt 0 ]]
do
	# Make sure the UID of the account is at least 1000.
	USERNAME="${1}"
	if [[ $(id -u $USERNAME) -lt 1000 ]]
	then	
		echo "You don't have permissions to execute this script on the account with username ${USERNAME}" >&2
		exit 1
	fi

	# Create an archive if requested to do so.
	if [[ "${ARCHIVE_HOME_DIRECTORY}" = 'true' ]]
	then
		echo "Archiving the home directory of the user ${USERNAME}..."

		# Make sure the ARCHIVE_DIR directory exists.
		mkdir -p $ARCHIVE_DIR

		# Archive the user's home directory and move it into the ARCHIVE_DIR
		tar -zcvf ${USERNAME}.tgz /home/${USERNAME}
		mv ${USERNAME}.tgz $ARCHIVE_DIR

		echo "Archived home directory of the user ${USERNAME}."
	fi

	# Removes the home directory associated with the account if requested to do so.
	if [[ "${REMOVE_HOME_DIRECTORY}" = 'true' ]]
	then
		echo "Removing the home directory of the user ${USERNAME}..."
		rm -rf /home/${USERNAME}
		echo "Removed the home directory of the user ${USERNAME}."
	fi

	# Delete the user if requested to do so. 
	if [[ "${DELETE_ACCOUNTS}" = 'true' ]]
	then
		echo "Deleting the user ${USERNAME}..."
		
		userdel ${USERNAME}	
		
		# Make sure the user got deleted
		if [[ "${?}" -ne 0 ]]
		then
			echo "The account ${USERNAME} was NOT deleted." >&2
			exit 1
		fi

		# Tell the user the account was deleted.
		echo "The account ${USERNAME} was deleted."
	else
		# Disable the user

		echo "Disabling the account ${USERNAME}..."

		chage -E 0 $USERNAME

		# Make sure the user got disabled.
		if [[ "${?}" -ne 0 ]]
		then
			echo "The account ${USERNAME} was NOT disabled." >&2
			exit 1
		fi

		# Tell the user the account was disabled.
		echo "The account ${USERNAME} was disabled."

	fi

	shift
done

exit 0
