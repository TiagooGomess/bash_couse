#!/bin/bash

# Make sure a file was supplied as an argument.
FILE="${1}"

if [[ ! -e ${FILE} ]]
then
	echo "Cannot open file ${FILE}" >&2
	exit 1
fi

# Display the CSV header.
echo 'Count,IP,Location'

# Loop through the list of failed attempts and corresponding IP addresses.
# If the number of failed attempts is greater than the limit, display count, IP, and location.

grep 'Failed password for' ${FILE} | cut -d ' ' -f 6- | grep -o 'from.*port' | cut -d ' ' -f 2 | sort | uniq -c | awk '$1 > 10' > occurrences.txt

while IFS= read -r line; do
	COUNT=$(echo "$line" | awk '{print $1}')
	IP=$(echo "${line}" | awk '{print $2}')
	LOCATION="$(geoiplookup ${IP} | awk -F ', ' '{print $NF}')"
	echo "${COUNT},${IP},${LOCATION}"
done < occurrences.txt | sort -nr
