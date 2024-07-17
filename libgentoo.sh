#!/bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR"/libbootstrap.sh

function IsPackageInstalled {
	if [ "$2" == "inOverlay" ]; then
		packageCheck=$(eix -IR "$1" | grep "No matches found")
	else
		packageCheck=$(eix -I "$1" | grep "No matches found")
	fi

	if [ "$packageCheck" != "" ]; then
		return 1
	fi

	return 0
}

function InstallQtile {
	WriteTaskName

	if ! IsPackageInstalled "x11-wm/qtile"; then
		packages=(
			# Tiling WM
			"x11-misc/picom"
			"lxde-base/lxappearance"
			"lxde-base/lxsession"
			"x11-misc/nitrogen"
			"media-sound/volumeicon"
			"x11-misc/arandr"
			# For qtile
			"dev-python/pip"
			"x11-wm/qtile"
		)

		for package in "${packages[@]}"; do
			if ! IsPackageInstalled "$package"; then
				echo "...emerge $package"
				return 1
			fi
		done
	fi

}

function InstallDiscord {
	WriteTaskName

	if ! IsPackageInstalled "net-im/discord"; then
		echo "...emerge net-im/discord"
		return 1
	fi
}

function InstallZsh {
	WriteTaskName

	if ! IsPackageInstalled "app-shells/zsh"; then
		echo "...Add the following global USE flag, then emerge zsh: zsh-completion"
		return 1
	fi
}

function InstallCoreUtilities {
	WriteTaskName

	if ! IsPackageInstalled "app-portage/gentoolkit"; then
		echo "...emerge app-portage/gentoolkit"
		return 1
	fi

	if ! IsPackageInstalled "app-admin/eclean-kernel"; then
		echo "...emerge app-admin/eclean-kernel"
		return 1
	fi

	if ! IsPackageInstalled "app-misc/tmux"; then
		echo "...emerge app-misc/tmux"
		return 1
	fi

	if ! IsPackageInstalled "app-arch/unar"; then
		echo "...emerge app-arch/unar"
		return 1
	fi

	if ! IsPackageInstalled "app-misc/fastfetch"; then
		echo "...emerge app-misc/fastfetch"
		return 1
	fi

	if ! IsPackageInstalled "sys-process/htop"; then
		echo "...emerge sys-process/htop"
		return 1
	fi

	# If this is a VM, install spice guest agent
	vmCheck=$(grep hypervisor </proc/cpuinfo)
	if [ "$vmCheck" != "" ]; then
		if ! IsPackageInstalled "spice-vdagent"; then
			echo "...emerge app-emulation/spice-vdagent"
			return 1
		fi
	fi

	if ! IsPackageInstalled "media-sound/pavucontrol"; then
		echo "emerge media-sound/pavucontrol"
		return 1
	fi

	if ! IsPackageInstalled "x11-misc/ulauncher" inOverlay; then
		echo "...emerge x11-misc/ulauncher, only available via overlay"
		return 1
	fi
}

function InstallFonts {
	WriteTaskName

	if ! IsPackageInstalled "media-fonts/fonts-meta"; then
		echo "...emerge media-fonts/fonts-meta"
		return 1
	fi

	if ! IsPackageInstalled "media-fonts/corefonts"; then
		echo "...emerge media-fonts/corefonts"
		return 1
	fi

	if ! IsPackageInstalled "media-fonts/fira-code"; then
		echo "...emerge media-fonts/fira-code"
		return 1
	fi

	if ! IsPackageInstalled "media-fonts/ubuntu-font-family"; then
		echo "...emerge media-fonts/ubuntu-font-family"
		return 1
	fi

	if ! IsPackageInstalled "media-fonts/noto-emoji"; then
		echo "...emerge media-fonts/noto-emoji"
		return 1
	fi

	InstallNerdFonts
}

function InstallFlatpak {
	WriteTaskName

	if ! IsPackageInstalled "sys-apps/flatpak"; then
		echo "...emerge sys-apps/flatpak"
		return 1
	fi

	if ! IsPackageInstalled "sys-apps/xdg-desktop-portal"; then
		echo "...emerge sys-apps/xdg-desktop-portal"
		return 1
	fi

	if ! IsPackageInstalled "sys-apps/xdg-desktop-portal-gtk"; then
		echo "...emerge sys-apps/xdg-desktop-portal-gtk"
		return 1
	fi

	EnableFlathubRepo
}

function EnsureAppImage {
	WriteTaskName

	# Fancy fuse check
	packageCheck=$(eix -I --exact sys-fs/fuse --installed-slot 0 | grep "No matches found")
	if [ "$packageCheck" == "No matches found" ]; then
		echo "...emerge sys-fs/fuse:0"
		return 1
	fi
}

function InstallWebBrowsers {
	WriteTaskName

	# Librewolf
	if ! IsPackageInstalled "www-client/librewolf" inOverlay; then
		echo "...emerge www-client/librewolf, only available via overlay"
		return 1
	fi

	# Fancy Firefox check
	firefoxCheck=$(eix -I --exact www-client/firefox | grep "No matches found")
	if [ "$firefoxCheck" == "No matches found" ]; then
		echo "...emerge www-client/firefox, may need to remove the bin version first"
		return 1
	fi

	# Chromium
	if ! IsPackageInstalled "www-client/ungoogled-chromium" inOverlay; then
		echo "...Ensure the following USE flags for chromium: proprietary-codecs widevine"
		echo "...emerge www-client/ungoogled-chromium, only available via overlay. Remember to mask vscode from this overlay."
		return 1
	fi
}
