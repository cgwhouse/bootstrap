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
2. Install git as a way of testing sudo with local user
3. Clone bootstrap repo

### TODO

- we want to get to a desktop environment as soon as possible, because of all the config files and manual shit required
- encourage following use flags: X, xinerama, elogind, networkmanager, -systemd, -kde, -plasma, -qt5 -qt6 -telemetry -wayland
- encourage wiki page for OpenRC commands and other manual edits needed
- we do not need a separate step for LightDM because the wiki handles it from the MATE page
- that leaves only pulseaudio and zsh-completion USE flags to go
- we need MATE, which has global USE flags elogind, xinerama, -systemd, X, -wayland

