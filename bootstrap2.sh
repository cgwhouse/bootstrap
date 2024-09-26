#!/bin/bash

if [ $# -gt 0 ]; then
	printf "\nUsage:\n\n"
	printf "./bootstrap2.sh\n"
	exit 1
fi

#region SHARED

function IsCommandAvailable {
	cmdCheck=$($1 2>/dev/null || echo "not found")

	if [ "$cmdCheck" == "not found" ]; then
		return 1
	fi

	return 0
}

function ConfigureTmux {
	ohMyTmuxPath="$HOME/.tmux"
	if [ ! -d "$ohMyTmuxPath" ]; then
		echo "...Installing Oh My Tmux"

		git clone https://github.com/gpakosz/.tmux.git "$ohMyTmuxPath"
		ln -sf "$ohMyTmuxPath"/.tmux.conf "$HOME"/.tmux.conf
		cp "$ohMyTmuxPath"/.tmux.conf.local "$HOME"/

		echo "...Successfully installed Oh My Tmux"
	fi

	# Ensure Tmux is fully configured, exit if not
	# Check for commented out mouse mode as the check, the default config has this
	if grep -Fxq "#set -g mouse on" "$HOME"/.tmux.conf.local; then
		echo "...WARNING: Oh My Tmux still needs to be configured"
	fi
}

function ConfigureZsh {
	if [ ! -d "$HOME/.oh-my-zsh" ]; then
		echo "...Installing Oh My Zsh, you will be dropped into a new zsh session at the end"
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	fi
}

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

function InstallDoomEmacs {

	if [ -d "$HOME"/.config/emacs ]; then
		return 0
	fi

	git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
	~/.config/emacs/bin/doom install
	echo "...Doom Emacs installed"
}

function InstallStudio3t {

	# TODO: maybe take another pass at trying to automate this
	if [ ! -d "$HOME"/studio3t ]; then
		echo "...NOTE: Install Studio3T here: https://studio3t.com/download/"
	fi
}

function DownloadNordTheme {
	if [ ! -d "$HOME"/.themes/Nordic-darker ]; then
		wget https://github.com/EliverLara/Nordic/releases/latest/download/Nordic-darker.tar.xz
		unar -d Nordic-darker.tar.xz
		mv Nordic-darker/Nordic-darker "$HOME"/.themes
		rm -rf Nordic-darker
		rm -f Nordic-darker.tar.xz
		echo "...Installed Nord theme"
	fi

	if [ ! -d "$HOME"/.local/share/icons/Nordzy-dark ]; then
		mkdir "$HOME"/repos/theming/Nordzy-icon
		git clone https://github.com/alvatip/Nordzy-icon.git "$HOME"/repos/theming/Nordzy-icon
		"$HOME"/repos/theming/Nordzy-icon/install.sh -d "$HOME"/.local/share/icons
		echo "...Installed Nordzy icon themes"
	fi

	# Ulauncher
	if [ ! -d "$HOME/.config/ulauncher/user-themes/nord" ]; then
		git clone https://github.com/KiranWells/ulauncher-nord/ "$HOME"/.config/ulauncher/user-themes/nord
		echo "...Installed Ulauncher Nord theme"
	fi

	# Currently no good Nord theme for Grub, so just clone distro-grub-themes
	if [ ! -d "$HOME"/repos/theming/distro-grub-themes ]; then
		mkdir "$HOME"/repos/theming/distro-grub-themes
		git clone https://github.com/AdisonCavani/distro-grub-themes.git "$HOME"/repos/theming/distro-grub-themes
		echo "...Cloned distro-grub-themes"
	fi

	# Wallpapers
	if [ ! -d "$HOME"/Pictures/wallpapers/nordic ]; then
		echo "...Installing Nordic wallpaper pack"
		mkdir "$HOME"/Pictures/wallpapers/nordic
		mkdir "$HOME"/repos/theming/nordic-wallpapers
		git clone https://github.com/linuxdotexe/nordic-wallpapers.git "$HOME"/repos/theming/nordic-wallpapers
		cp -r "$HOME"/repos/theming/nordic-wallpapers/wallpapers/*.png "$HOME"/Pictures/wallpapers/nordic
		cp -r "$HOME"/repos/theming/nordic-wallpapers/wallpapers/*.jpg "$HOME"/Pictures/wallpapers/nordic
		echo "...Nordic wallpaper pack installed"
	fi

	# Tmux
	if ! grep -Fxq "set -g @plugin 'arcticicestudio/nord-tmux'" "$HOME"/.tmux.conf.local; then
		echo "...NOTE: Set Nord tmux theme by adding the following to .tmux.conf.local: set -g @plugin 'arcticicestudio/nord-tmux'"
	fi
}

function InstallDBeaverFlatpak {
	dbeaverCheck=$(flatpak list | grep dbeaver)
	if [ "$dbeaverCheck" == "" ]; then
		echo "...Installing DBeaver"
		flatpak install -y flathub io.dbeaver.DBeaverCommunity
		echo "...DBeaver installed"
	fi
}

function InstallPostmanFlatpak {
	postmanCheck=$(flatpak list | grep Postman)
	if [ "$postmanCheck" == "" ]; then
		echo "...Installing Postman"
		flatpak install -y flathub com.getpostman.Postman
		echo "...Postman installed"
	fi
}

function InstallGitCredentialManager {
	# Global config
	configCheck=$(git config --list | grep credential.credentialstore=secretservice)
	if [ "$configCheck" == "" ]; then
		git config --global credential.credentialStore secretservice
		echo "...Updated git credentialStore config"
	fi

	if ! IsCommandAvailable "git-credential-manager --help"; then
		curl -L https://aka.ms/gcm/linux-install-source.sh | bash
		git-credential-manager configure
	fi
}

function InstallNvm {
	if [ ! -d "$HOME"/.nvm ]; then
		wget -O- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
		echo "...nvm installed"
	fi
}

#endregion

#region DEBIAN

function AptPackageIsInstalled {
	package=$1

	installed=$(apt list --installed 2>/dev/null)

	# Exclude pkgs known to have naming conflicts with the ones we actually want to check for
	# Conflicts exist currently for unar and VSCode
	if [ "$package" == "code" ]; then
		packageCheck=$(echo "$installed" | grep "$1/" | grep -v "intel-microcode" | grep -v "dmidecode" | grep -v "fonts-firacode")
	elif [ "$package" == "unar" ]; then
		packageCheck=$(echo "$installed" | grep "$1/" | grep -v "thunar")
	else
		packageCheck=$(echo "$installed" | grep "$1/")
	fi

	if [ "$packageCheck" != "" ]; then
		return 0
	fi

	return 1
}

function AptInstallMissingPackages {
	packages=("$@")

	for package in "${packages[@]}"; do
		if ! AptPackageIsInstalled "$package"; then
			sudo apt install -y "$package"

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
	echo "NOTE: You may be prompted multiple times for input"

	# Check various package sources first, if any need updating we will run apt update after
	aptUpdateNeeded=false

	# Ensure apt sources include contrib and non-free,
	# default netinstall only has main and non-free-firmware
	aptSourcesCheck=$(grep "contrib non-free" </etc/apt/sources.list)

	if [ "$aptSourcesCheck" == "" ]; then
		sudo sed -i 's/main non-free-firmware/main contrib non-free non-free-firmware/g' /etc/apt/sources.list

		aptUpdateNeeded=true
		echo "...Added 'contrib non-free' to Debian sources"
	fi

	# Ulauncher
	if ! compgen -G "/etc/apt/sources.list.d/ulauncher*" >/dev/null; then
		gpg --keyserver keyserver.ubuntu.com --recv 0xfaf1020699503176
		gpg --export 0xfaf1020699503176 | sudo tee /usr/share/keyrings/ulauncher-archive-keyring.gpg >/dev/null

		echo "deb [signed-by=/usr/share/keyrings/ulauncher-archive-keyring.gpg] \
		    http://ppa.launchpad.net/agornostal/ulauncher/ubuntu jammy main" |
			sudo tee /etc/apt/sources.list.d/ulauncher-jammy.list

		aptUpdateNeeded=true
		echo "...Added ulauncher package source"
	fi

	# Firefox (from Mozilla repo)
	if ! compgen -G "/etc/apt/sources.list.d/mozilla*" >/dev/null; then
		sudo install -d -m 0755 /etc/apt/keyrings
		wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc >/dev/null

		echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list >/dev/null

		echo '
			Package: *
			Pin: origin packages.mozilla.org
			Pin-Priority: 1000
			' | sudo tee /etc/apt/preferences.d/mozilla

		aptUpdateNeeded=true
		echo "...Added up-to-date Firefox package source"
	fi

	# .NET
	if ! compgen -G "/etc/apt/sources.list.d/microsoft-prod*" >/dev/null; then
		wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
		sudo dpkg -i packages-microsoft-prod.deb
		rm packages-microsoft-prod.deb

		aptUpdateNeeded=true
		echo "...Added .NET SDK package source"
	fi

	# VS Code
	if ! compgen -G "/etc/apt/sources.list.d/vscode*" >/dev/null; then
		wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
		sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg

		echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
		rm -f packages.microsoft.gpg

		aptUpdateNeeded=true
		echo "...Added VSCode package source"
	fi

	if $aptUpdateNeeded; then
		echo "...Updating sources"
		sudo apt update
	fi

	# Now that we have proper Firefox source setup, replace the ESR version
	if AptPackageIsInstalled "firefox-esr"; then
		sudo apt remove -y firefox-esr && sudo apt autopurge -y && sudo apt-get autoclean -y
	fi

	if ! AptPackageIsInstalled "firefox"; then
		sudo apt install -y "firefox"
	fi

	packages=(
		"git"
		"vim"
		"zsh"
		"tmux"
		"htop"
		"unar"
		"aptitude"
		"apt-transport-https"
		"neofetch"
		"spice-vdagent"
		"ulauncher"
		"plank"
		"pipewire-audio"
		"ttf-mscorefonts-installer"
		"fonts-firacode"
		"fonts-ubuntu"
		"fonts-noto-color-emoji"
		"flatpak"
		"dotnet-sdk-7.0"
		"dotnet-sdk-8.0"
		"code"
		"emacs-gtk"
		"ripgrep"
		"fd-find"
		"elpa-ligature"
		"vlc"
		"gparted"
		"awscli"
		"sshpass"
		"default-jdk"
		"tuned"
	)

	echo "...Checking for and installing missing packages"

	if ! AptInstallMissingPackages "${packages[@]}"; then
		echo "Failed to install packages"
		return 1
	fi

	# Do systemd-resolved separately, because reboot required
	# for internet to work again after install
	if ! AptPackageIsInstalled "systemd-resolved"; then
		sudo apt install -y systemd-resolved

		if ! AptPackageIsInstalled "systemd-resolved"; then
			echo "ERROR: Failed to install systemd-resolved"
			return 1
		else
			echo "...Successfully installed systemd-resolved, reboot and run script again to continue"
			return 0
		fi
	fi

	CreateDirectories
	ConfigureTmux
	InstallNerdFonts
	EnableFlathubRepo
	InstallDoomEmacs
	InstallDBeaverFlatpak
	InstallPostmanFlatpak
	DownloadNordTheme
	InstallGitCredentialManager
	InstallNvm
	InstallStudio3t

	# Install old libssl (for AWS VPN)
	if ! AptPackageIsInstalled "libssl1.1"; then
		wget http://http.us.debian.org/debian/pool/main/o/openssl/libssl1.1_1.1.1w-0+deb11u1_amd64.deb -O libssl.deb
		sudo dpkg -i libssl.deb

		if ! AptPackageIsInstalled "libssl1.1"; then
			echo "ERROR: Failed to install libssl"
			return 1
		fi

		rm -f libssl.deb
		echo "...Installed libssl"
	fi

	ConfigureZsh
}

function BootstrapDebianServer {
	echo "Bootstrapping Debian Server..."
	echo "NOTE: You may be prompted multiple times for input"

	# Check various package sources first, if any need updating we will run apt update after
	aptUpdateNeeded=false

	# Ensure apt sources include contrib and non-free,
	# default netinstall only has main and non-free-firmware
	aptSourcesCheck=$(grep "contrib non-free" </etc/apt/sources.list)

	if [ "$aptSourcesCheck" == "" ]; then
		sudo sed -i 's/main non-free-firmware/main contrib non-free non-free-firmware/g' /etc/apt/sources.list

		aptUpdateNeeded=true
		echo "...Added 'contrib non-free' to Debian sources"
	fi

	# .NET
	if ! compgen -G "/etc/apt/sources.list.d/microsoft-prod*" >/dev/null; then
		wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
		sudo dpkg -i packages-microsoft-prod.deb
		rm packages-microsoft-prod.deb

		aptUpdateNeeded=true
		echo "...Added .NET SDK package source"
	fi

	if $aptUpdateNeeded; then
		echo "...Updating sources"
		sudo apt update
	fi

	packages=(
		"git"
		"vim"
		"zsh"
		"tmux"
		"htop"
		"unar"
		"aptitude"
		"apt-transport-https"
		"neofetch"
		"dotnet-sdk-7.0"
		"dotnet-sdk-8.0"
		"awscli"
		"default-jdk"
	)

	echo "...Checking for and installing missing packages"

	if ! AptInstallMissingPackages "${packages[@]}"; then
		echo "Failed to install packages"
		return 1
	fi

	CreateDirectories
	ConfigureTmux
	InstallNvm
	ConfigureZsh
}

#endregion

#region FEDORA

function BootstrapFedora {
	echo "Bootstrapping Fedora..."

	#max_parallel_downloads=10
	#fastestmirror=True

}

#endregion

#region GENTOO

function BootstrapGentoo {
	echo "Bootstrapping Gentoo..."
}

#endregion

function Main {
	printf "\nWelcome to boostrap2!\n\n"
	printf "Select a workflow:\n\n"

	select workflow in "Debian (Server)" "Debian (VM)" "Fedora" "Gentoo" "Exit"; do
		case $workflow in
		"Debian (Server)")
			BootstrapDebianServer
			break
			;;
		"Debian (VM)")
			BootstrapDebianVM
			break
			;;
		"Fedora")
			BootstrapFedora
			break
			;;
		"Gentoo")
			BootstrapGentoo
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

	printf "\nDone!\n"
}

Main
