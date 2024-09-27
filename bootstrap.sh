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

	flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
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

function DownloadCatppuccinTheme {
	WriteTaskName

	# GTK + icons
	accentColors=(
		"blue"
		"flamingo"
		"green"
		"lavender"
		"maroon"
		"mauve"
		"peach"
		"pink"
		"red"
		"rosewater"
		"sapphire"
		"sky"
		"teal"
		"yellow"
	)

	for accentColor in "${accentColors[@]}"; do

		if [ ! -d "$HOME"/.themes/catppuccin-mocha-"$accentColor"-standard+default ]; then
			wget https://github.com/catppuccin/gtk/releases/latest/download/catppuccin-mocha-"$accentColor"-standard+default.zip
			unar -d catppuccin-mocha-"$accentColor"-standard+default.zip
			mv catppuccin-mocha-"$accentColor"-standard+default/catppuccin-mocha-"$accentColor"-standard+default "$HOME"/.themes
			rm -rf catppuccin-mocha-"$accentColor"-standard+default
			rm -f catppuccin-mocha-"$accentColor"-standard+default.zip
			echo "...Installed Catppuccin GTK Mocha $accentColor theme"
		fi

	done

	if [ ! -d "$HOME"/.local/share/icons/Tela-dark ]; then
		mkdir "$HOME"/repos/theming/Tela-icon-theme
		git clone https://github.com/vinceliuice/Tela-icon-theme.git "$HOME"/repos/theming/Tela-icon-theme
		"$HOME"/repos/theming/Tela-icon-theme/install.sh -a -c -d "$HOME"/.local/share/icons
		echo "...Installed Tela icon themes"
	fi

	# Ulauncher
	if ! compgen -G "$HOME/.config/ulauncher/user-themes/Catppuccin-Mocha*" >/dev/null; then
		python3 <(curl https://raw.githubusercontent.com/catppuccin/ulauncher/main/install.py -fsSL) -f all -a all &>/dev/null
		echo "...Installed Ulauncher Catppuccin themes"
	fi

	# Grub
	if [ ! -d /usr/share/grub/themes/catppuccin-mocha-grub-theme ]; then
		mkdir "$HOME"/repos/theming/catppuccin-grub
		git clone https://github.com/catppuccin/grub.git "$HOME"/repos/theming/catppuccin-grub
		echo "...Cloned Catppuccin grub theme to themes directory"
	fi

	# Wallpapers
	if [ ! -d "$HOME"/Pictures/wallpapers/catppuccin ]; then
		echo "...Installing Catppuccin wallpaper pack"
		mkdir "$HOME"/Pictures/wallpapers/catppuccin
		mkdir "$HOME"/repos/theming/catppuccin-wallpapers
		git clone https://github.com/Gingeh/wallpapers.git "$HOME"/repos/theming/catppuccin-wallpapers
		cp -r "$HOME"/repos/theming/catppuccin-wallpapers/*/*.png "$HOME"/Pictures/wallpapers/catppuccin
		cp -r "$HOME"/repos/theming/catppuccin-wallpapers/*/*.jpg "$HOME"/Pictures/wallpapers/catppuccin
		echo "...Catppuccin wallpaper pack installed"
	fi

	# Tmux
	if ! grep -Fxq "set -g @plugin 'catppuccin/tmux'" "$HOME"/.tmux.conf.local; then
		echo "NOTE: Set Catppuccin tmux theme by adding the following to .tmux.conf.local: set -g @plugin 'catppuccin/tmux'"
	fi
}

function FlatpakPackageIsInstalled {
	package=$1

	packageCheck=$(flatpak list | grep "$package")
	if [ "$packageCheck" != "" ]; then
		return 0
	fi

	return 1
}

function FlatpakInstallMissingPackages {
	packages=("$@")

	for package in "${packages[@]}"; do
		if ! FlatpakPackageIsInstalled "$package"; then
			flatpak install --user -y "$package"

			# Check again, error if not installed
			if ! FlatpakPackageIsInstalled "$package"; then
				echo "ERROR: Failed to install $package"
				return 1
			fi
		fi
	done

	return 0
}

function InstallFlatpaks {

	flatpaks=(
		"com.discordapp.Discord"
		"com.spotify.Client"
		"com.slack.Slack"
		"com.github.IsmaelMartinez.teams_for_linux"
		"us.zoom.Zoom"
		"dev.vencord.Vesktop"
		"com.snes9x.Snes9x"
		"org.duckstation.DuckStation"
		"io.github.simple64.simple64"
		"net.pcsx2.PCSX2"
		"net.rpcs3.RPCS3"
		"net.kuribo64.melonDS"
	)

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

function ConfigureVirtManager {
	# Ensure libvirtd and tuned services are enabled
	# This service will not stay running if in a VM, so only do this part if no VM detected
	vmCheck=$(grep hypervisor </proc/cpuinfo)

	libvirtdCheck=$(sudo systemctl is-active libvirtd.service)
	if [ "$vmCheck" == "" ] && [ "$libvirtdCheck" == "inactive" ]; then
		sudo systemctl enable --now libvirtd.service
		echo "...libvirtd service enabled"
	fi

	tunedCheck=$(sudo systemctl is-active tuned.service)
	if [ "$tunedCheck" == "inactive" ]; then
		sudo systemctl enable --now tuned.service
		echo "...tuned service enabled"
	fi

	# Set autostart on virtual network
	virshNetworkCheck=$(sudo virsh net-list --all --autostart | grep default)
	if [ "$virshNetworkCheck" == "" ]; then
		sudo virsh net-autostart default
		echo "...Virtual network set to autostart"
	fi

	# Add regular user to libvirt group
	groupCheck=$(groups "$USER" | grep libvirt)
	if [ "$groupCheck" == "" ]; then
		sudo usermod -aG libvirt "$USER"
		echo "...User added to libvirt group"
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
		packageCheck=$(echo "$installed" | grep "$package/" | grep -v "intel-microcode" | grep -v "dmidecode" | grep -v "fonts-firacode")
	elif [ "$package" == "unar" ]; then
		packageCheck=$(echo "$installed" | grep "$package/" | grep -v "thunar")
	else
		packageCheck=$(echo "$installed" | grep "$package/")
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

function AllDebianSourcesAreEnabled {
	aptSourcesCheck=$(grep "contrib non-free" </etc/apt/sources.list)

	if [ "$aptSourcesCheck" == "" ]; then
		return 0
	fi

	return 1
}

function EnableAllDebianSources {
	sudo sed -i 's/main non-free-firmware/main contrib non-free non-free-firmware/g' /etc/apt/sources.list
	echo "...Added 'contrib non-free' to Debian sources"
}

function DotNetAptSourceIsEnabled {
	if compgen -G "/etc/apt/sources.list.d/microsoft-prod*" >/dev/null; then
		return 0
	fi

	return 1
}

function EnableDotNetAptSource {
	wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
	sudo dpkg -i packages-microsoft-prod.deb
	rm packages-microsoft-prod.deb
	echo "...Added .NET SDK package source"
}

function BootstrapDebianVM {
	echo "Bootstrapping Debian VM..."
	echo "NOTE: You may be prompted multiple times for input"

	# Check various package sources first, if any need updating we will run apt update after
	aptUpdateNeeded=false

	# Ensure apt sources include contrib and non-free,
	# default netinstall only has main and non-free-firmware
	if ! AllDebianSourcesAreEnabled; then
		EnableAllDebianSources
		aptUpdateNeeded=true
	fi

	# .NET
	if ! DotNetAptSourceIsEnabled; then
		EnableDotNetAptSource
		aptUpdateNeeded=true
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

	EnableFlathubRepo

	flatpaks=(
		"io.dbeaver.DBeaverCommunity"
		"com.getpostman.Postman"
	)

	if ! FlatpakInstallMissingPackages "${flatpaks[@]}"; then
		echo "Failed to install flatpaks"
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
	InstallNvm
	InstallNerdFonts
	InstallDoomEmacs
	InstallStudio3t
	InstallGitCredentialManager
	DownloadNordTheme

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

	# Check various package sources first, if any need updating we will run apt update after
	aptUpdateNeeded=false

	# Ensure apt sources include contrib and non-free,
	# default netinstall only has main and non-free-firmware
	if ! AllDebianSourcesAreEnabled; then
		EnableAllDebianSources
		aptUpdateNeeded=true
	fi

	# .NET
	if ! DotNetAptSourceIsEnabled; then
		EnableDotNetAptSource
		aptUpdateNeeded=true
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
		"default-jdk-headless"
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

function DnfPackageIsInstalled {
	package=$1

	installed=$(dnf list --installed 2>/dev/null)

	# Exclude pkgs known to have naming conflicts with the ones we actually want to check for
	# Conflicts exist currently for VSCode
	if [ "$package" == "code" ] || [ "$package" == "emacs" ]; then
		packageCheck=$(echo "$installed" | grep "$package.x86_64")
	elif [ "$package" == "default-fonts" ]; then
		packageCheck=$(echo "$installed" | grep "$package.noarch")
	else
		packageCheck=$(echo "$installed" | grep "$package")
	fi

	if [ "$packageCheck" != "" ]; then
		return 0
	fi

	return 1
}

function DnfInstallMissingPackages {
	packages=("$@")

	for package in "${packages[@]}"; do
		if ! DnfPackageIsInstalled "$package"; then
			sudo dnf install -y "$package"

			# Check again, error if not installed
			if ! DnfPackageIsInstalled "$package"; then
				echo "ERROR: Failed to install $package"
				return 1
			fi
		fi
	done

	return 0
}

function BootstrapFedora {
	echo "Bootstrapping Fedora..."
	echo "NOTE: You may be prompted multiple times for input"

	# Configure dnf with fastest mirror and parallel downloads
	dnfFastestMirrorCheck=$(grep "fastestmirror=True" </etc/dnf/dnf.conf)
	if [ "$dnfFastestMirrorCheck" == "" ]; then
		echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf >/dev/null
		echo "...set fastestmirror=True in dnf.conf"
	fi

	dnfParallelDownloadsCheck=$(grep "max_parallel_downloads=10" </etc/dnf/dnf.conf)
	if [ "$dnfParallelDownloadsCheck" == "" ]; then
		echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf >/dev/null
		echo "...set max_parallel_downloads=10 in dnf.conf"
	fi

	# Repo for Ubuntu fonts
	coprCheck=$(dnf copr list | grep "ubuntu-fonts")
	if [ "$coprCheck" == "" ]; then
		sudo dnf copr enable -y atim/ubuntu-fonts
		echo "...ubuntu-fonts copr repository enabled"
	fi

	# Repo for Ungoogled Chromium
	coprCheck=$(dnf copr list | grep "ungoogled-chromium")
	if [ "$coprCheck" == "" ]; then
		sudo dnf copr enable -y wojnilowicz/ungoogled-chromium
		echo "...ungoogled-chromium copr repository enabled"
	fi

	# Repo for Visual Studio Code
	vscodeCheck=$(dnf repolist | grep "Visual Studio Code")
	if [ "$vscodeCheck" == "" ]; then
		sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc &>/dev/null
		echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
		echo "...VS Code repo enabled"
	fi

	packages=(
		# Core
		"vim-enhanced"
		"neovim"
		"python3-neovim"
		"zsh"
		"htop"
		"unar"
		"fastfetch"
		"python3-dnf-plugin-rpmconf"
		"ulauncher"
		# Fonts
		"default-fonts"
		"fira-code-fonts"
		"ubuntu-family-fonts"
		"cabextract"
		"xorg-x11-font-utils"
		"fontconfig"
		# Dev
		"ungoogled-chromium"
		"alacritty"
		"code"
		"dotnet-sdk-8.0"
		"pavucontrol"
		"emacs"
		"ripgrep"
		"fd-find"
		"vlc"
		"obs-studio"
		"libreoffice"
		"aisleriot"
		"gnome-mines"
		"gparted"
		"sshpass"
		"awscli2"
		"java-17-openjdk"
		# VM
		"qemu-kvm"
		"libvirt"
		"virt-install"
		"virt-manager"
		"virt-viewer"
		"edk2-ovmf"
		"swtpm"
		"qemu-img"
		"guestfs-tools"
		"libosinfo"
		# Fun
		"steam"
		"wine"
		"transmission"
		"lutris"
		"dolphin-emu"
		"qflipper"
	)

	echo "...Checking for and installing missing packages"

	if ! DnfInstallMissingPackages "${packages[@]}"; then
		echo "Failed to install packages"
		return 1
	fi

	EnableFlathubRepo

	flatpaks=(
		"com.discordapp.Discord"
		"com.spotify.Client"
		"com.slack.Slack"
		"com.github.IsmaelMartinez.teams_for_linux"
		"us.zoom.Zoom"
		"dev.vencord.Vesktop"
		"com.snes9x.Snes9x"
		"org.duckstation.DuckStation"
		"io.github.simple64.simple64"
		"net.pcsx2.PCSX2"
		"net.rpcs3.RPCS3"
		"net.kuribo64.melonDS"
		"io.mgba.mGBA"
		"io.dbeaver.DBeaverCommunity"
		"com.getpostman.Postman"
	)

	if ! FlatpakInstallMissingPackages "${flatpaks[@]}"; then
		echo "Failed to install flatpaks"
		return 1
	fi

	# Microsoft fonts
	if [ ! -d "/usr/share/fonts/msttcore" ]; then
		sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
		echo "...Installed MSFT fonts"
	fi

	CreateDirectories
	ConfigureTmux
	InstallNvm
	InstallNerdFonts
	InstallDoomEmacs
	InstallStudio3t
	InstallGitCredentialManager
	ConfigureVirtManager
	DownloadNordTheme
	DownloadCatppuccinTheme
	ConfigureZsh
}

#endregion

#region GENTOO

function BootstrapGentoo {
	echo "Bootstrapping Gentoo..."
}

#endregion

function Main {
	printf "\nWelcome to bootstrap2!\n\n"
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
