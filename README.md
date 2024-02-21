# bootstrap

## Debian

1. Update apt sources (optional)
2. Full update of system using apt
3. Reboot
4. Install git
5. Clone bootstrap repo
6. Edit server flag (optional)
7. Run bootstrap-debian.sh

## Gentoo

1. Follow the Handbook in its entirety, until at a tty
2. Ensure dist-kernel and nvidia USE flags
2. Install git and neovim
3. Setup eix via the wiki
4. Clone bootstrap repo
5. Run bootstrap-gentoo.sh, follow instructions

### TODO

- we want to get to a desktop environment as soon as possible, because of all the config files and manual shit required
- encourage following use flags: X, xinerama, elogind, networkmanager, -systemd, -kde, -plasma, -qt5 -qt6 -telemetry -wayland
- encourage wiki page for OpenRC commands and other manual edits needed
- we do not need a separate step for LightDM because the wiki handles it from the MATE page
- I think I need neovim and eix set up so I can query easily for installed packages...
- that leaves only pulseaudio and zsh-completion USE flags to go
- we need MATE, which has global USE flags elogind, xinerama, -systemd, X, -wayland
- font routine is semi shared, but using unar currently
  - could break out the package installs into their own OS specific which then call a common one
  - this same principle would be good for themeing task as well

