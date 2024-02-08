#!/bin/bash

# Environment variables
source ./.env

# Globals
aptUpdated=false

function CheckForPackageAndInstallIfMissing {
    # Check for package using dpkg-query
    # If it exits without an error, package was found and we can exit
    if dpkg-query -W "$1" &>/dev/null; then
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

function InstallCoreUtilities {
    echo "TASK: InstallCoreUtilities"

    packages=("neovim" "zsh" "curl" "wget" "tmux" "htop")

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
    echo "TASK: ConfigureProprietaryGraphics"

    # If this is a server bootstrap, exit
    if [ $server == true ]; then
        return 0
    fi

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
