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

function UpdateAptSources {
	echo "...Updating sources"
	sudo apt update
}

function InstallPackageIfMissingViaApt {
	packageToCheck=$1
	grepStr="installed"

	# Handle 32-bit
	# TODO: may not need 32-bit pkgs for VM
	# should we have separate routines for determining which packages are missing if any?

	if [[ "$packageToCheck" == *":i386"* ]]; then
		# Strip i386 from the package name that was provided
		packageToCheck="${packageToCheck/:i386/""}"
		# Update the string used by grep to check if installed
		grepStr="i386 \[installed\]"
	fi

	# Check for package using apt list
	packageCheck=$(apt list "$packageToCheck" 2>/dev/null | grep "$grepStr")
	if [ "$packageCheck" != "" ]; then
		return 0
	fi

	# If apt update hasn't run yet, do that now
	#if [ $aptUpdated = false ]; then
	#	UpdateAptSources
	#fi

	echo "...Installing $1"
	sudo apt install -y "$1"

	# Ensure package was installed, return error if not
	installCheck=$(apt list "$packageToCheck" 2>/dev/null | grep "$grepStr")
	if [ "$installCheck" == "" ]; then
		echo "ERROR: Failed to install $1"
		return 1
	fi

	echo "...Successfully installed $1"
	return 0
}

function InstallListOfAptPackages {
	packages=("$@")

	for package in "${packages[@]}"; do

		if ! InstallPackageIfMissingViaApt "$package"; then
			return 1
		fi

	done

	return 0
}

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

function GetMissingPackagesFromList {
	packages=("$@")
	result=()

	# Get list of installed packages
	installed=$(apt list --installed 2>/dev/null)

	for package in "${packages[@]}"; do
		packageCheck=$(echo "$installed" | grep "$package")

		if [ "$packageCheck" == "" ]; then
			result+=("$package")
		fi
	done

	return "${result[@]}"

	#echo "hello"

	#packageToCheck=$1
	#grepStr="installed"

	# Handle 32-bit
	# TODO: may not need 32-bit pkgs for VM
	# should we have separate routines for determining which packages are missing if any?

	#if [[ "$packageToCheck" == *":i386"* ]]; then
	#	# Strip i386 from the package name that was provided
	#	packageToCheck="${packageToCheck/:i386/""}"
	#	# Update the string used by grep to check if installed
	#	grepStr="i386 \[installed\]"
	#fi

	# Check for package using apt list
	#packageCheck=$(apt list "$packageToCheck" 2>/dev/null | grep "$grepStr")
	#if [ "$packageCheck" != "" ]; then
	#	return 0
	#fi
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

	packages=(
		"neofetch"
		"libreoffice"
	)

	#missing=$(GetMissingPackagesFromList "${packages[@]}")

	for package in "${packages[@]}"; do

		if ! AptPackageIsInstalled "$package"; then
			echo "Would be installing $package"
			#sudo apt install -y "$package"
		fi

		#packageCheck=$(apt list --installed 2>/dev/null | grep "$package")

		#if [ "$packageCheck" == "" ]; then
		#	result+=("$package")
		#fi

	done

	#if ! InstallListOfPackagesIfMissing "${packages[@]}"; then
	#	return 1
	#fi
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
