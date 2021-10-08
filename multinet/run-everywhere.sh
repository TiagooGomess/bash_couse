#!/bin/bash

SERVERS_FILE='/vagrant/servers'

# Display the usage and exit.
usage() {
	echo "Usage: ${0} [-nsv] [-f FILE]" >&2
	echo "Executes a given command on multiple servers." >&2
	echo "	-n			Allows the user to perform a \"dry run\" where the commands will be displayed instead of executed." >&2
	echo "	-s			Run the command with sudo (superuser) privileges on the remote servers." >&2
	echo "	-v			Enable the verbose mode, which displays the name of the server for which the command is being executed on." >&2
	echo "	-f FILE		Allows the user to override the default file of /vagrant/servers." >&2
	exit 1
}

log() {
	local MESSAGE="${@}"
	if [[ "${VERBOSE_MODE}" = 'true' ]]
	then
		echo "${MESSAGE}"
	fi
}

# Make sure the script is being executed without superuser privileges.
if [[ "${UID}" -eq 0 ]]
then
	echo "You cannot execute this script with root privileges." >&2
	usage
	exit 1
fi

# Parse the options.
while getopts nsvf: OPTION
do
	case ${OPTION} in
		n)
			DRY_RUN='true'
			;;
		s)
			SUDO='sudo'
			;;
		v)
			VERBOSE_MODE='true'
			;;
		f)
			SERVERS_FILE="${OPTARG}"
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
	echo 'You need to provide a command.' >&2
	usage
fi

COMMAND="${@}"

if [[ ! -e "${SERVERS_FILE}" ]]
then
	echo "The file ${SERVERS_FILE} does not exist." >&2
	exit 1
fi

for SERVER in $(cat ${SERVERS_FILE})
do
	log "Executing \"${COMMAND}\" on ${SERVER}"
	if [[ "${DRY_RUN}" = 'true' ]]
	then
		echo "DRY RUN: ssh -o ConnectTimeout=2 ${SERVER} ${SUDO} ${COMMAND}"
	else
		ssh -o ConnectTimeout=2 ${SERVER} "${SUDO} ${COMMAND}"
		EXIT_STATUS="${?}"
		if [[ "${EXIT_STATUS}" -ne 0 ]]
		then
			echo "The command \"${COMMAND}\" was exited with an exit code of ${EXIT_STATUS}" >&2
		fi
	fi
done

