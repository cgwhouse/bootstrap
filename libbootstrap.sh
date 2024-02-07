#!/bin/bash

function PrintUsageAndExit {
    printf "\nUsage:\n\n"
    printf "sudo ./bootstrap.sh\n\n"
    return 1
}

# Globals
username=cristian
aptUpdated=false

function InstallPackageWithApt {

    # If apt update hasn't run yet, do that now
    if [ $aptUpdated = false ]; then
        sudo apt update &> /dev/null
        aptUpdated=true
    fi

    echo "...Installing $1"

    sudo apt install -y "$1" &> /dev/null

    echo "...Successfully installed $1"

    return 0
}

function CheckWithCommandAndInstallIfMissing {
    # The command that should be used to determine if program exists
    commandToCheck=$1

    # Special case for neovim
    if [ "$1" == "neovim" ]; then
        commandToCheck="nvim"
    fi

    if ! (hash "$commandToCheck" 2> /dev/null); then
        InstallPackageWithApt "$1"
    fi

    return 0
}

function InstallCoreUtilities {
    echo "TASK: InstallCoreUtilities"

    packages=("git" "neovim" "zsh" "curl" "wget" "tmux")

    for package in "${packages[@]}"; do
        CheckWithCommandAndInstallIfMissing "$package"
    done

    return 0
}

function ConfigureCoreUtilities {
    echo "TASK: ConfigureCoreUtilities"

    # Ensure zsh is default shell for user
    userShell=$(getent passwd $username | awk -F: '{print $NF}')
    if [ "$userShell" != "/usr/bin/zsh" ]; then
        echo "...Changing default shell to zsh"
        sudo usermod --shell /usr/bin/zsh $username
        echo "...Default shell changed to zsh"
    fi

    # Oh My Tmux
    ohMyTmuxPath="/home/$username/.tmux"
    if [ ! -d $ohMyTmuxPath ]; then
        echo "...Installing Oh My Tmux"

        sudo -u $username git clone https://github.com/gpakosz/.tmux.git $ohMyTmuxPath
        sudo -u $username ln -s -f $ohMyTmuxPath/.tmux.conf /home/$username/.tmux.conf
        sudo -u $username cp $ohMyTmuxPath/.tmux.conf.local /home/$username/

        echo "...Successfully installed Oh My Tmux"
    fi

    # Ensure Tmux is fully configured, exit if not

    # Oh My Zsh
    if [ ! -d "/home/$username/.oh-my-zsh" ]; then
        echo "...Installing Oh My Zsh. It's recommended to log out and log back in after this"
        sudo -u $username sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        echo "...Successfully installed Oh My Zsh"
    fi

    return 0
}
