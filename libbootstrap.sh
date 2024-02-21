#!/bin/bash

function CreateDirectories {
    echo "TASK: CreateDirectories"

    if [ ! -d "$HOME"/repos ]; then
        mkdir "$HOME"/repos &>/dev/null
        echo "...Created repos directory"
    fi

    if [ ! -d "$HOME"/repos/theming ]; then
        mkdir "$HOME"/repos/theming &>/dev/null
        echo "...Created theming directory"
    fi

    if [ ! -d "$HOME"/Pictures ]; then
        mkdir "$HOME"/Pictures &>/dev/null
        echo "...Created Pictures directory"
    fi

    if [ ! -d "$HOME"/Pictures/wallpapers ]; then
        mkdir "$HOME"/Pictures/wallpapers &>/dev/null
        echo "...Created wallpapers directory"
    fi

    if [ ! -d "$HOME"/.cache ]; then
        mkdir "$HOME"/.cache &>/dev/null
        echo "...Created .cache directory"
    fi

    if [ ! -d "$HOME/.local" ]; then
        mkdir "$HOME"/.local
        echo "...Created .local directory"
    fi

    if [ ! -d "$HOME/.local/share" ]; then
        mkdir "$HOME"/.local/share
        echo "...Created local share directory"
    fi

    if [ ! -d "$HOME/.local/bin" ]; then
        mkdir "$HOME"/.local/bin
        echo "...Created local bin directory"
    fi
}

function ConfigureCoreUtilities {
    echo "TASK: ConfigureCoreUtilities"

    # Ensure zsh is default shell for user
    userShell=$(getent passwd "$USER" | awk -F: '{print $NF}')
    if [ "$userShell" != "/usr/bin/zsh" ]; then
        echo "...Changing default shell to zsh"
        sudo usermod --shell /usr/bin/zsh "$USER" &>/dev/null
        echo "...Default shell changed to zsh"
    fi

    # Oh My Tmux
    ohMyTmuxPath="$HOME/.tmux"
    if [ ! -d "$ohMyTmuxPath" ]; then
        echo "...Installing Oh My Tmux"

        git clone https://github.com/gpakosz/.tmux.git "$ohMyTmuxPath" &>/dev/null
        ln -s -f "$ohMyTmuxPath"/.tmux.conf "$HOME"/.tmux.conf &>/dev/null
        cp "$ohMyTmuxPath"/.tmux.conf.local "$HOME"/ &>/dev/null

        echo "...Successfully installed Oh My Tmux"
    fi

    # Ensure Tmux is fully configured, exit if not
    # Check for commented out mouse mode as the check, the default config has this
    if grep -Fxq "#set -g mouse on" "$HOME"/.tmux.conf.local; then
        echo "...WARNING: Oh My Tmux still needs to be configured"
    fi
}

function InstallNvm {
    echo "TASK: InstallNvm"

    if [ ! -d "$HOME"/.nvm ]; then
        wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash &>/dev/null
        echo "...nvm installed"
    fi
}

function InstallOhMyZsh {
    echo "TASK: InstallOhMyZsh"

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "...Installing Oh My Zsh, you will be dropped into a new zsh session at the end"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
}
