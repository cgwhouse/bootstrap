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

function InstallNerdFonts {
	localFontsDir="$HOME/.local/share/fonts"

	firaCodeNerdFontCheck="$localFontsDir/FiraCodeNerdFont-Regular.ttf"
	if [ ! -f "$firaCodeNerdFontCheck" ]; then
		echo "...Installing FiraCode Nerd Font"
		curl -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip -o fira.zip
		unar -d fira.zip
		cp fira/*.ttf "$localFontsDir"
		rm -r fira
		rm fira.zip
		echo "...FiraCode Nerd Font installed"
	fi

	ubuntuNerdFontCheck="$localFontsDir/UbuntuNerdFont-Regular.ttf"
	if [ ! -f "$ubuntuNerdFontCheck" ]; then
		echo "...Installing Ubuntu Nerd Font"
		curl -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Ubuntu.zip -o ubuntu.zip
		unar -d ubuntu.zip
		cp ubuntu/*.ttf "$localFontsDir"
		rm -r ubuntu
		rm ubuntu.zip
		echo "...Ubuntu Nerd Font installed"
	fi

	ubuntuMonoNerdFontCheck="$localFontsDir/UbuntuMonoNerdFont-Regular.ttf"
	if [ ! -f "$ubuntuMonoNerdFontCheck" ]; then
		echo "...Installing UbuntuMono Nerd Font"
		curl -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/UbuntuMono.zip -o ubuntumono.zip
		unar -d ubuntumono.zip
		cp ubuntumono/*.ttf "$localFontsDir" &>/dev/null
		rm -r ubuntumono
		rm ubuntumono.zip
		echo "...UbuntuMono Nerd Font installed"
	fi
}

function EnableFlathubRepo {
	flathubCheck=$(flatpak remotes | grep flathub)
	if [ "$flathubCheck" != "" ]; then
		return 0
	fi

	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	echo "...Flathub repository added"
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

	# Check package sources first, if any need updating we will run apt update after
	aptUpdateNeeded=false

	# Ensure apt sources include contrib and non-free,
	# default netinstall only has main and non-free-firmware
	aptSourcesCheck=$(grep "contrib non-free" </etc/apt/sources.list)

	if [ "$aptSourcesCheck" == "" ]; then
		echo "DEBUG: would have updated apt sources"
		#sudo sed -i 's/main non-free-firmware/main contrib non-free non-free-firmware/g' /etc/apt/sources.list

		#aptUpdateNeeded=true
	fi

	# TODO: maybe we should do all sources right at the start?
	# Setup source for ulauncher package if needed
	if ! compgen -G "/etc/apt/sources.list.d/ulauncher*" >/dev/null; then
		echo "DEBUG: would have added ulauncher source"
		#gpg --keyserver keyserver.ubuntu.com --recv 0xfaf1020699503176
		#gpg --export 0xfaf1020699503176 | sudo tee /usr/share/keyrings/ulauncher-archive-keyring.gpg >/dev/null

		#echo "deb [signed-by=/usr/share/keyrings/ulauncher-archive-keyring.gpg] \
		#    http://ppa.launchpad.net/agornostal/ulauncher/ubuntu jammy main" |
		#	sudo tee /etc/apt/sources.list.d/ulauncher-jammy.list

		#aptUpdateNeeded=true
	fi

	if ! compgen -G "/etc/apt/sources.list.d/mozilla*" >/dev/null; then
		echo "DEBUG: would have added firefox source"

		#		sudo install -d -m 0755 /etc/apt/keyrings
		#		wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc >/dev/null
		#		echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list >/dev/null
		#
		#		echo '
		#	Package: *
		#	Pin: origin packages.mozilla.org
		#	Pin-Priority: 1000
		#	' | sudo tee /etc/apt/preferences.d/mozilla

		#aptUpdateNeeded=true
	fi

	# .NET
	if ! compgen -G "/etc/apt/sources.list.d/microsoft-prod*" >/dev/null; then
		echo "DEBUG: would have added firefox source"

		#echo "...Setting up .NET SDK package source"
		#wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
		#sudo dpkg -i packages-microsoft-prod.deb
		#rm packages-microsoft-prod.deb

		aptUpdateNeeded=true
		#UpdateAptSources
	fi

	if $aptUpdateNeeded; then
		echo "...Updating sources"
		sudo apt update
	fi

	# Now that we have proper Firefox source setup, remove the ESR version
	# that came packaged
	if AptPackageIsInstalled "firefox-esr"; then
		sudo apt remove -y firefox-esr && sudo apt autopurge && sudo apt-get autoclean -y
	fi

	packages=(
		"git"
		"vim"
		"zsh"
		"curl"
		"wget"
		"tmux"
		"htop"
		"unar"
		"aptitude"
		"apt-transport-https"
		"gpg" # TODO: might break out if not included in default, so we can frontload apt sources
		"gnupg"
		"ca-certificates"
		"neofetch"
		"spice-vdagent"
		"ulauncher"
		"pipewire-audio"
		"pavucontrol"
		"ttf-mscorefonts-installer"
		"fonts-firacode"
		"fonts-ubuntu"
		"fonts-noto-color-emoji"
		"flatpak"
		"firefox"
		"dotnet-sdk-7.0"
		"dotnet-sdk-8.0"
	)

	# DEBUG
	packages=(
		"neofetch"
		"libreoffice"
	)

	if ! AptInstallMissingPackages "${packages[@]}"; then
		echo "Failed to install initial packages"
		return 1
	fi

	#CreateDirectories
	#InstallNerdFonts
	#EnableFlathubRepo
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
