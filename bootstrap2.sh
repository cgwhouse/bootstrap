#!/bin/bash

if [ $# -gt 0 ]; then
	printf "\nUsage:\n\n"
	printf "./bootstrap2.sh\n"
	exit 1
fi

#region SHARED

function CreateDirectories {
	directories=(
		"$HOME/repos"
		"$HOME/repos/theming"
		"$HOME/Pictures"
		"$HOME/Pictures/wallpapers"
		"$HOME/.cache"
		"$HOME/.local"
		"$HOME/.local/bin"
		"$HOME/.local/share"
		"$HOME/.local/share/applications"
		"$HOME/.local/share/fonts"
		"$HOME/.local/share/icons"
		"$HOME/.themes"
	)

	for directory in "${directories[@]}"; do
		if [ ! -d "$directory" ]; then
			mkdir "$directory"
			echo "...Created $directory"
		fi
	done
}

#endregion

#region DEBIAN

function AptPackageIsInstalled {
	package=$1

	# Get list of installed packages
	installed=$(apt list --installed 2>/dev/null)

	packageCheck=$(echo "$installed" | grep "$1")

	if [ "$packageCheck" != "" ]; then
		return 0
	fi

	return 1
}

function AptInstallMissingPackages {
	packages=("$@")

	for package in "${packages[@]}"; do
		if ! AptPackageIsInstalled "$package"; then
			echo "DEBUG: Would be installing $package"
			#sudo apt install -y "$package"

			# Check again, error if not installed
			if ! AptPackageIsInstalled "$package"; then
				echo "ERROR: Failed to install $package"
				return 1
			fi
		fi
	done

	return 0
}

function BootstrapDebianVM {
	echo "Bootstrapping Debian VM..."

	# TODO: update default apt sources if needed.
	# maybe we should do all sources right at the start?

	# Setup source for ulauncher package if needed
	#if ! compgen -G "/etc/apt/sources.list.d/ulauncher*" >/dev/null; then
	#	echo "...Setting up ulauncher package source"
	#	gpg --keyserver keyserver.ubuntu.com --recv 0xfaf1020699503176
	#	gpg --export 0xfaf1020699503176 | sudo tee /usr/share/keyrings/ulauncher-archive-keyring.gpg >/dev/null

	#	echo "deb [signed-by=/usr/share/keyrings/ulauncher-archive-keyring.gpg] \
	#        http://ppa.launchpad.net/agornostal/ulauncher/ubuntu jammy main" |
	#		sudo tee /etc/apt/sources.list.d/ulauncher-jammy.list

	#	#UpdateAptSources
	#fi

	#CreateDirectories

	#packages=(
	#	"git"
	#	"vim"
	#	#"neovim"
	#	"zsh"
	#	"curl"
	#	"wget"
	#	"tmux"
	#	"htop"
	#	"unar"
	#	"aptitude"
	#	"apt-transport-https"
	#	#"ntp"
	#	"gpg"
	#	"gnupg"
	#	"ca-certificates"
	#	"neofetch"
	#	"spice-vdagent"
	#)

	# DEBUG
	packages=(
		"neofetch"
		"libreoffice"
	)

	if ! AptInstallMissingPackages "${packages[@]}"; then
		echo "Failed to install initial packages"
		return 1
	fi
}

#endregion

#region FEDORA

function BootstrapFedora {
	echo "Bootstrapping Fedora..."
}

#endregion

function Main {
	printf "\nWelcome to boostrap2!\n\n"
	printf "Select a workflow:\n\n"

	select workflow in "Fedora" "Debian VM" "Exit"; do
		case $workflow in
		"Fedora")
			BootstrapFedora
			break
			;;
		"Debian VM")
			BootstrapDebianVM
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

	printf "\n"
}

Main
