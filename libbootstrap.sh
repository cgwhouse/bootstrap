#!/bin/bash

function WriteTaskName {
	echo "TASK: ${FUNCNAME[1]}"
}

function NvidiaCheck {
	nvidiaHardwareCheck=$(lspci | grep NVIDIA | awk -F: '{print $NF}')
	if [ "$nvidiaHardwareCheck" == "" ]; then
		return 1
	fi
}

function EnableFlathubRepo {
	flathubCheck=$(sudo flatpak remotes | grep flathub)
	if [ "$flathubCheck" != "" ]; then
		return 0
	fi

	sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	echo "...Flathub repository added"
}

function CreateDirectories {
	WriteTaskName

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
	WriteTaskName

	# Oh My Tmux
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

function InstallNvm {
	WriteTaskName

	if [ ! -d "$HOME"/.nvm ]; then
		wget -O- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
		echo "...nvm installed"
	fi
}

function ConfigureZsh {
	WriteTaskName

	if [ ! -d "$HOME/.oh-my-zsh" ]; then
		echo "...Installing Oh My Zsh, you will be dropped into a new zsh session at the end"
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	fi
}

function InstallNerdFonts {
	WriteTaskName

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

### BEGIN DEPRECATED ###

#function DownloadPlankThemeCommon {
#	if [ ! -d "$HOME"/.local/share/plank ]; then
#		mkdir "$HOME"/.local/share/plank
#		echo "...Created plank directory"
#	fi
#
#	if [ ! -d "$HOME"/.local/share/plank/themes ]; then
#		mkdir "$HOME"/.local/share/plank/themes
#		echo "...Created plank themes directory"
#	fi
#
#	if [ ! -d "$HOME"/.local/share/plank/themes/Catppuccin-mocha ]; then
#		mkdir "$HOME"/repos/theming/catppuccin-plank
#		git clone https://github.com/catppuccin/plank.git "$HOME"/repos/theming/catppuccin-plank &>/dev/null
#		cp -r "$HOME"/repos/theming/catppuccin-plank/src/Catppuccin-mocha "$HOME"/.local/share/plank/themes &>/dev/null
#		echo "...Installed Catppuccin plank theme"
#	fi
#}

### END DEPRECATED ###
