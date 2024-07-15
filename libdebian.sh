#!/bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR"/libbootstrap.sh

aptUpdated=false

function UpdateAptSources {
	echo "...Updating sources"
	sudo apt update
	aptUpdated=true
}

function InstallPackageIfMissing {
	packageToCheck=$1
	grepStr="installed"

	# Handle 32-bit
	if [[ "$packageToCheck" == *":i386"* ]]; then
		# Strip i386 from the package name that was provided
		packageToCheck="${packageToCheck/:i386/""}"
		# Update the string used by grep to check if installed
		grepStr="i386 \[installed\]"
	fi

	# Check for package using apt list
	packageCheck=$(sudo apt list "$packageToCheck" 2>/dev/null | grep "$grepStr")
	if [ "$packageCheck" != "" ]; then
		return 0
	fi

	# If apt update hasn't run yet, do that now
	if [ $aptUpdated = false ]; then
		UpdateAptSources
	fi

	echo "...Installing $1"
	sudo apt install -y "$1"

	# Ensure package was installed, return error if not
	installCheck=$(sudo apt list "$packageToCheck" 2>/dev/null | grep "$grepStr")
	if [ "$installCheck" == "" ]; then
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
		"curl"
		"wget"
		"tmux"
		"htop"
		"unar"
		"aptitude"
		"apt-transport-https"
		"ntp"
		"gpg"
		"gnupg"
		"ca-certificates"
    "fastfetch"
	)

	if ! InstallListOfPackagesIfMissing "${corePackages[@]}"; then
		return 1
	fi

	# If this is a VM, install spice guest agent
	vmCheck=$(grep hypervisor </proc/cpuinfo)
	if [ "$vmCheck" != "" ]; then
		if ! InstallPackageIfMissing spice-vdagent; then
			return 1
		fi
	fi
}

function EnableMultiarch {
	WriteTaskName

	multiarchCheck=$(dpkg --print-foreign-architectures | grep i386)
	if [ "$multiarchCheck" != "" ]; then
		return 0
	fi

	echo "...Adding i386 architecture"
	sudo dpkg --add-architecture i386

	UpdateAptSources
}

function InstallProprietaryGraphics {
	WriteTaskName

	if ! NvidiaCheck; then
		return 0
	fi

	nvidiaPackages=(
		"linux-headers-amd64"
		"firmware-misc-nonfree"
		"nvidia-driver"
		"nvidia-driver-libs:i386"
		"nvidia-cuda-dev"
		"nvidia-cuda-toolkit"
	)

	if ! InstallListOfPackagesIfMissing "${nvidiaPackages[@]}"; then
		return 1
	fi
}

function InstallDesktopEnvironment {
	WriteTaskName

	# Setup source for ulauncher package if needed
	if ! compgen -G "/etc/apt/sources.list.d/ulauncher*" >/dev/null; then
		echo "...Setting up ulauncher package source"
		gpg --keyserver keyserver.ubuntu.com --recv 0xfaf1020699503176
		gpg --export 0xfaf1020699503176 | sudo tee /usr/share/keyrings/ulauncher-archive-keyring.gpg >/dev/null

		echo "deb [signed-by=/usr/share/keyrings/ulauncher-archive-keyring.gpg] \
          http://ppa.launchpad.net/agornostal/ulauncher/ubuntu jammy main" |
			sudo tee /etc/apt/sources.list.d/ulauncher-jammy.list

		UpdateAptSources
	fi

	desktop=$1
	if [ "$desktop" == "gnome" ]; then
		desktopPackages=(
			"task-gnome-desktop"
			"ulauncher"
		)
	elif [ "$desktop" == "cinnamon" ]; then
		desktopPackages=(
			"lightdm"
			"task-cinnamon-desktop"
			"ulauncher"
		)
	elif [ "$desktop" == "mate" ]; then
		desktopPackages=(
			"lightdm"
			"task-mate-desktop"
			"mate-desktop-environment-extras"
			"xscreensaver"
			"ulauncher"
		)
	elif [ "$desktop" == "qtile" ]; then
		desktopPackages=(
			"lightdm"
			"xserver-xorg"
			"xinit"
			"xscreensaver"
			"picom"
			"lxappearance"
			"lxsession"
			"nitrogen"
			"volumeicon-alsa"
			"arandr"
			"python-is-python3"
			"python3-pip"
			"pipx"
			"libpangocairo-1.0-0"
			"python3-xcffib"
			"python3-cairocffi"
			"python3-dbus-next"
			"ulauncher"
		)
	fi

	if ! InstallListOfPackagesIfMissing "${desktopPackages[@]}"; then
		return 1
	fi
}

function InstallPipewire {
	WriteTaskName

	audioPackages=(
		"pipewire-audio"
		"pavucontrol"
	)

	if ! InstallListOfPackagesIfMissing "${audioPackages[@]}"; then
		return 1
	fi
}

function InstallFonts {
	WriteTaskName

	fontPackages=(
		"ttf-mscorefonts-installer"
		"fonts-firacode"
		"fonts-ubuntu"
		"fonts-noto-color-emoji"
	)

	if ! InstallListOfPackagesIfMissing "${fontPackages[@]}"; then
		return 1
	fi

	InstallNerdFonts
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

	# Setup source for Ungoogled Chromium package if needed
	if ! compgen -G "/etc/apt/sources.list.d/home:ungoogled_chromium*" >/dev/null; then
		echo "...Setting up Ungoogled Chromium package source"
		echo 'deb http://download.opensuse.org/repositories/home:/ungoogled_chromium/Debian_Sid/ /' | sudo tee /etc/apt/sources.list.d/home:ungoogled_chromium.list
		curl -fsSL https://download.opensuse.org/repositories/home:ungoogled_chromium/Debian_Sid/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_ungoogled_chromium.gpg >/dev/null

		UpdateAptSources
	fi

	# Setup source for LibreWolf package if needed
	if ! compgen -G "/etc/apt/sources.list.d/librewolf*" >/dev/null; then
		echo "...Setting up LibreWolf package source"
		wget -O- https://deb.librewolf.net/keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/librewolf.gpg

		sudo tee /etc/apt/sources.list.d/librewolf.sources <<EOF >/dev/null
Types: deb
URIs: https://deb.librewolf.net
Suites: bookworm
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/librewolf.gpg
EOF

		UpdateAptSources
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
