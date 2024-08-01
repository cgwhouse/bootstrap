#!/bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR"/libbootstrap.sh

zypperUpdated=false

function UpdateZypperSources {
	echo "...Updating sources"
	sudo zypper refresh
	zypperUpdated=true
}

function InstallPackageIfMissing {
	packageToCheck=$1
	grepStr="No matching items found."

	# Check for package using zypper se
	packageCheck=$(zypper se --installed-only "$packageToCheck" 2>/dev/null | grep "$grepStr")
	if [ "$packageCheck" == "" ]; then
		return 0
	fi

	# If zypper refresh hasn't run yet, do that now
	if [ $zypperUpdated = false ]; then
		UpdateZypperSources
	fi

	echo "...Installing $1"
	sudo zypper install -y "$1"

	# Ensure package was installed, return error if not
	installCheck=$(zypper se --installed-only "$packageToCheck" 2>/dev/null | grep "$grepStr")
	if [ "$installCheck" != "" ]; then
		echo "ERROR: Failed to install $1"
		return 1
	fi

	echo "...Successfully installed $1"
	return 0
}

function InstallListOfPackagesIfMissing {
	packages=("$@")

	for package in "${packages[@]}"; do

		if ! InstallPackageIfMissing "$package"; then
			return 1
		fi

	done

	return 0
}

function InstallCoreUtilities {
	WriteTaskName

	corePackages=(
		"vim"
		"neovim"
		"zsh"
		"tmux"
		"htop"
		"fastfetch"
	)

	if ! InstallListOfPackagesIfMissing "${corePackages[@]}"; then
		return 1
	fi

	ulauncherCheck=$(zypper se --installed-only ulauncher | grep "No matching items found.")
	if [ "$ulauncherCheck" != "" ]; then
		sudo zypper addrepo https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Tumbleweed/home:Dead_Mozay.repo

		InstallPackageIfMissing ulauncher
	fi
}

function InstallProprietaryGraphics {
	WriteTaskName

	if ! NvidiaCheck; then
		return 0
	fi

	grepStr="No matching items found."

	# Check for nvidia package, if missing do the recommended command from wiki
	packageCheck=$(zypper se --installed-only "nvidia-gl" 2>/dev/null | grep "$grepStr")
	if [ "$packageCheck" == "" ]; then
		return 0
	fi

	sudo zypper install -y openSUSE-repos-Tumbleweed-NVIDIA
	sudo zypper install-new-recommends --repo repo-non-free
}

function InstallFonts {
	WriteTaskName

	# Repo for Ubuntu fonts
	#coprCheck=$(sudo dnf copr list | grep "ubuntu-fonts")
	#if [ "$coprCheck" == "" ]; then
	#	sudo dnf copr enable -y atim/ubuntu-fonts
	#	echo "...ubuntu-fonts copr repository enabled"
	#fi

	fontPackages=(
		"ubuntu-fonts"
		"google-noto-coloremoji-fonts"
		"fira-code-fonts"
		"fetchmsttfonts"
	)

	#fontPackages=(
	#		"default-fonts"
	#		"default-fonts-core-emoji"
	#		"fira-code-fonts"
	#		"ubuntu-family-fonts"
	#		"cabextract"
	#		"xorg-x11-font-utils"
	#		"fontconfig"
	#	)

	if ! InstallListOfPackagesIfMissing "${fontPackages[@]}"; then
		return 1
	fi

	InstallNerdFonts

	## Microsoft fonts
	#if [ ! -d "/usr/share/fonts/msttcore" ]; then
	#	sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
	#	echo "...Installed MSFT fonts"
	#fi
}

function InstallFlatpak {
	WriteTaskName

	if ! InstallPackageIfMissing flatpak; then
		return 1
	fi

	EnableFlathubRepo
}

function InstallWebBrowsers {
	WriteTaskName

	# Repo for Ungoogled Chromium
	coprCheck=$(sudo dnf copr list | grep "ungoogled-chromium")
	if [ "$coprCheck" == "" ]; then
		sudo dnf copr enable -y wojnilowicz/ungoogled-chromium
		echo "...ungoogled-chromium copr repository enabled"
	fi

	# Repo for LibreWolf
	librewolfRepoCheck=$(dnf repolist | grep "LibreWolf")
	if [ "$librewolfRepoCheck" == "" ]; then
		curl -fsSL https://rpm.librewolf.net/librewolf-repo.repo | pkexec tee /etc/yum.repos.d/librewolf.repo
		echo "...LibreWolf repo enabled. Do a manual distro-sync to accept the GPG key, then continue the script."
		return 1
	fi

	browserPackages=(
		"firefox"
		"ungoogled-chromium"
		"librewolf"
	)

	if ! InstallListOfPackagesIfMissing "${browserPackages[@]}"; then
		return 1
	fi
}
