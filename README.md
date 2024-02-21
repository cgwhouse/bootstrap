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
3. Install git + vim + neovim
3. Setup eix via the wiki
4. Sync + depclean and eselect editor
5. Clone bootstrap repo
6. Run bootstrap-gentoo.sh, follow instructions

### TODO

- we want to get to a desktop environment + web browser as soon as possible, because of all the config files and manual shit required
- that leaves only pulseaudio and zsh-completion USE flags to go
- font routine is semi shared, but using unar currently
  - could break out the package installs into their own OS specific which then call a common one
  - this same principle would be good for themeing task as well
- next up after mate + browser: audio + pavucontrol, zsh, tmux / whatever else in configure utilities
