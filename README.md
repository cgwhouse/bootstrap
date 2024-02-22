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
4. depclean, reboot
5. Clone bootstrap repo
6. Run bootstrap-gentoo.sh, follow instructions

### TODO

- all the ones that can be installed normally / without configs should be in their own big routine that cycles through package names
- add vdagent guest package if VM detected in InstallCoreUtilities
- rename main scripts for easier tab complete / reruns
- bookmark places to check for updated versions
