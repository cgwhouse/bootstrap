#!/bin/bash

# Environment variables
source ./.env &>/dev/null

aptUpdated=false

function CheckForPackageAndInstallIfMissing {
    # Check for package using apt list
    packageCheck=$(sudo apt list "$1" 2>/dev/null | grep installed)
    if [ "$packageCheck" != "" ]; then
        return 0
    fi

    # If apt update hasn't run yet, do that now
    if [ $aptUpdated = false ]; then
        echo "...Running apt update"
        sudo apt update &>/dev/null
        aptUpdated=true
    fi

    echo "...Installing $1"
    sudo apt install -y "$1" &>/dev/null
    echo "...Successfully installed $1"

    return 0
}

function CreateReposDirectory {
    echo "TASK: CreateReposDirectory"

    if [ ! -d /home/$username/repos ]; then
        sudo -u $username mkdir /home/$username/repos &>/dev/null
        echo "...Created repos directory"
    fi

    return 0
}

function InstallCoreUtilities {
    echo "TASK: InstallCoreUtilities"

    packages=("neovim" "zsh" "curl" "wget" "tmux" "htop" "unar" "neofetch")

    for package in "${packages[@]}"; do
        CheckForPackageAndInstallIfMissing "$package"
    done

    return 0
}

function ConfigureCoreUtilities {
    echo "TASK: ConfigureCoreUtilities"

    # Ensure zsh is default shell for user
    userShell=$(getent passwd $username | awk -F: '{print $NF}')
    if [ "$userShell" != "/usr/bin/zsh" ]; then
        echo "...Changing default shell to zsh"
        sudo usermod --shell /usr/bin/zsh $username &>/dev/null
        echo "...Default shell changed to zsh"
    fi

    # Oh My Tmux
    ohMyTmuxPath="/home/$username/.tmux"
    if [ ! -d $ohMyTmuxPath ]; then
        echo "...Installing Oh My Tmux"

        sudo -u $username git clone https://github.com/gpakosz/.tmux.git $ohMyTmuxPath &>/dev/null
        sudo -u $username ln -s -f $ohMyTmuxPath/.tmux.conf /home/$username/.tmux.conf &>/dev/null
        sudo -u $username cp $ohMyTmuxPath/.tmux.conf.local /home/$username/ &>/dev/null

        echo "...Successfully installed Oh My Tmux"
    fi

    # Ensure Tmux is fully configured, exit if not
    # Check for commented out mouse mode as the check, the default config has this
    if grep -Fxq "#set -g mouse on" /home/$username/.tmux.conf.local; then
        echo "ERROR: Oh My Tmux must be configured, rerun script after configuring"
        return 1
    fi

    return 0
}

function InstallProprietaryGraphics {
    echo "TASK: InstallProprietaryGraphics"

    # Check for NVIDIA hardware using lspci, exit if not found
    nvidiaHardwareCheck=$(lspci | grep NVIDIA | awk -F: '{print $NF}')
    if [ "$nvidiaHardwareCheck" == "" ]; then
        return 0
    fi

    # Kernel headers
    CheckForPackageAndInstallIfMissing linux-headers-amd64

    # non-free firmware
    CheckForPackageAndInstallIfMissing firmware-misc-nonfree

    # Main driver
    CheckForPackageAndInstallIfMissing nvidia-driver

    return 0
}

function InstallDesktopEnvironment {
    echo "TASK: InstallDesktopEnvironment"

    # Display manager
    CheckForPackageAndInstallIfMissing lightdm

    # Standard MATE + extras
    CheckForPackageAndInstallIfMissing mate-desktop-environment
    CheckForPackageAndInstallIfMissing mate-desktop-environment-extras

    # Dock
    CheckForPackageAndInstallIfMissing plank

    # App Launcher (requires extra setup)

    # Exit if already installed
    if dpkg-query -W ulauncher &>/dev/null; then
        return 0
    fi

    # Setup keyring using gnupg and export
    CheckForPackageAndInstallIfMissing gnupg
    sudo -u $username gpg --keyserver keyserver.ubuntu.com --recv 0xfaf1020699503176 &>/dev/null
    sudo -u $username gpg --export 0xfaf1020699503176 | sudo tee /usr/share/keyrings/ulauncher-archive-keyring.gpg >/dev/null

    # Add source with exported keyring to sources
    echo "deb [signed-by=/usr/share/keyrings/ulauncher-archive-keyring.gpg] \
          http://ppa.launchpad.net/agornostal/ulauncher/ubuntu jammy main" |
        sudo tee /etc/apt/sources.list.d/ulauncher-jammy.list &>/dev/null

    # Do a manual apt update here so we can get the new source and install package
    # Ensure flag is true if not already
    sudo apt update &>/dev/null
    aptUpdated=true

    # Install now
    CheckForPackageAndInstallIfMissing ulauncher

    # On Sid this sometimes doesn't work and need to manually install dependency
    # Check and error if this happened
    if ! dpkg-query -W ulauncher &>/dev/null; then
        echo "ERROR: ulauncher could not be installed, install manually and rerun script"
        return 1
    fi

    return 0
}

function InstallFonts {
    echo "TASK: Install Fonts"

    if [ ! -d "/home/$username/.local/share/fonts" ]; then
        sudo -u $username mkdir /home/$username/.local/share/fonts
        echo "...Fonts directory created"
    fi

    # MSFT
    CheckForPackageAndInstallIfMissing ttf-mscorefonts-installer

    # Fira Code + Nerd Font
    CheckForPackageAndInstallIfMissing fonts-firacode

    firaCodeNerdFontCheck="/home/$username/.local/share/fonts/FiraCodeNerdFont-Regular.ttf"
    if [ ! -f $firaCodeNerdFontCheck ]; then
        echo "...Installing FiraCode Nerd Font"
        curl -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip -o fira.zip &>/dev/null
        unar -d fira.zip &>/dev/null
        cp fira/*.ttf /home/$username/.local/share/fonts &>/dev/null
        rm -r fira &>/dev/null
        rm fira.zip &>/dev/null
        echo "...FiraCode Nerd Font installed"
    fi

    # Ubuntu + Nerd Font + UbuntuMono Nerd Font
    CheckForPackageAndInstallIfMissing fonts-ubuntu

    ubuntuNerdFontCheck="/home/$username/.local/share/fonts/UbuntuNerdFont-Regular.ttf"
    if [ ! -f $ubuntuNerdFontCheck ]; then
        echo "...Installing Ubuntu Nerd Font"
        curl -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Ubuntu.zip -o ubuntu.zip &>/dev/null
        unar -d ubuntu.zip &>/dev/null
        cp ubuntu/*.ttf /home/$username/.local/share/fonts &>/dev/null
        rm -r ubuntu &>/dev/null
        rm ubuntu.zip &>/dev/null
        echo "...Ubuntu Nerd Font installed"
    fi

    ubuntuMonoNerdFontCheck="/home/$username/.local/share/fonts/UbuntuMonoNerdFont-Regular.ttf"
    if [ ! -f $ubuntuMonoNerdFontCheck ]; then
        echo "...Installing UbuntuMono Nerd Font"
        curl -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/UbuntuMono.zip -o ubuntumono.zip &>/dev/null
        unar -d ubuntumono.zip &>/dev/null
        cp ubuntumono/*.ttf /home/$username/.local/share/fonts &>/dev/null
        rm -r ubuntumono &>/dev/null
        rm ubuntumono.zip &>/dev/null
        echo "...UbuntuMono Nerd Font installed"
    fi

    # Noto Emoji
    CheckForPackageAndInstallIfMissing fonts-noto-color-emoji
}

function InstallPipewire {
    echo "TASK: InstallPipewire"

    CheckForPackageAndInstallIfMissing pipewire-audio
    CheckForPackageAndInstallIfMissing pavucontrol
}

function InstallAdditionalSoftware {
    echo "TASK: InstallAdditionalSoftware"

    # NetworkManager
    CheckForPackageAndInstallIfMissing network-manager-gnome
    CheckForPackageAndInstallIfMissing network-manager-openvpn-gnome

    # TODO vs code
    CheckForPackageAndInstallIfMissing emacs-gtk
    CheckForPackageAndInstallIfMissing ripgrep
    CheckForPackageAndInstallIfMissing fd-find

    # TODO spotify

    # Remote stuff
    CheckForPackageAndInstallIfMissing sshpass
    # TODO digital ocean

    # Media
    CheckForPackageAndInstallIfMissing vlc
    CheckForPackageAndInstallIfMissing transmission-gtk
    CheckForPackageAndInstallIfMissing obs-studio

    # Misc utils
    CheckForPackageAndInstallIfMissing gparted
    CheckForPackageAndInstallIfMissing copyq
    CheckForPackageAndInstallIfMissing awscli

    # Game related things
    CheckForPackageAndInstallIfMissing aisleriot
    CheckForPackageAndInstallIfMissing gnome-mines
    CheckForPackageAndInstallIfMissing mgba-qt
    CheckForPackageAndInstallIfMissing lutris
    CheckForPackageAndInstallIfMissing dolphin-emu

    return 0
}

function InstallDotNetCore {
    echo "TASK: InstallDotNetCore"

    CheckForPackageAndInstallIfMissing dotnet-sdk-7.0
    CheckForPackageAndInstallIfMissing dotnet-sdk-8.0

    return 0
}

function InstallOhMyZsh {
    echo "TASK: InstallOhMyZsh"

    if [ ! -d "/home/$username/.oh-my-zsh" ]; then
        echo "...Installing Oh My Zsh"
        sudo -u $username sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &>/dev/null
        # TODO maybe not needed since it drops you into zsh anyway
        echo "...Successfully installed Oh My Zsh"
    fi

    return 0
}
