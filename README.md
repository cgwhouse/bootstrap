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
3. Install git + vim + neovim, eselect editor
3. Setup eix via the wiki
4. Sync + depclean
5. Clone bootstrap repo
6. Run bootstrap-gentoo.sh, follow instructions

### TODO

- we want to get to a desktop environment + web browser as soon as possible, because of all the config files and manual shit required
- can put off the web browser if additional things that don't need extra configuring / looking up stuff
- all the ones that can be installed normally / without configs should be in their own bit routine that cycles through package names
- maybe standard part of install is getting firefox-bin, then replacing with regular after we have librewolf and / or chromium?
- that leaves only pulseaudio USE flag to go
- font routine is semi shared, but using unar currently
  - could break out the package installs into their own OS specific which then call a common one
  - this same principle would be good for themeing task as well
- next up after mate + browser: audio + pavucontrol, zsh, tmux / whatever else in configure utilities
