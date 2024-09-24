#!/bin/bash

if [ $# -gt 0 ]; then
	printf "\nUsage:\n\n"
	printf "./bootstrap2.sh\n"
	exit 1
fi

printf "\nWelcome to boostrap2!\n"

printf "Select a workflow:\n\n"

select workflow in "Fedora" "Debian VM" "Exit"; do
	case $workflow in
	"Fedora")
		break
		;;
	"Debian VM")
		break
		;;
	"Exit")
		exit
		;;
	*)
		echo "Use the numbers in the list to make a selection"
		;;
	esac
done

echo "$workflow"

printf "\n"
