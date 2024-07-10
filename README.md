# bootstrap

Welcome to Flavortown

## Debian

1. Install via net installer, deselect all tasks for minimal installation
2. If using on the desktop:
   - [Update apt sources to Testing](https://wiki.debian.org/DebianTesting)
   - [Add Unstable packages with lower priority](https://wiki.debian.org/DebianUnstable)
   - Update system and reboot
3. Install git and clone this repo
4. Set optional flag in debian.sh:
   - If headless environment is intended: `server=true`
5. Run debian.sh
6. Move bootstrap directory to repos
7. Reboot

## Fedora

1. Install via ISO of desired desktop environment
2. Configure dnf parallel downloads and fastest mirror
3. Update system and reboot
4. [Enable RPM Fusion repos](https://docs.fedoraproject.org/en-US/quick-docs/rpmfusion-setup/)
5. Install codecs + H264 using docs in the following order:
   - Fedora quick docs for Multimedia
   - Fedora quick docs for OpenH264
   - Fedora Gaming docs for Steam (just line that mentions OpenH264)
   - RPM Fusion docs for Multimedia
6. Install git and clone this repo
7. Run fedora.sh
8. Move bootstrap directory to repos
9. Reboot

## Gentoo

1. Follow the Handbook, but do not reboot when it says to
2. Continue through post-reboot portion of handbook and complete remaining steps
3. Make note of anything that shouldn't be done ahead of time (removing
   stage3 tarball, disabling root user, etc.) so we can do it later
4. Install and configure eix
5. Install and configure NetworkManager
6. Install git + vim + neovim, eselect editor, depclean
7. Clone this repo
8. Run gentoo.sh, proceed until desktop environment and web browser are installed
9. Reboot, continue remaining setup via gentoo.sh

## Arch

To have the GUI of another computer to aid with install:

1. Boot installation media
2. Set root password via `passwd`
3. Do `PermitRootLogin yes` in `etc/ssh/sshd_config`
4. `systemctl start sshd`
5. Get IP via `ip addr`
6. ssh via other machine

Follow the Installation Guide:

1. When partitioning the disks, use suggested layout on Arch wiki,
   but use Gentoo wiki for fdisk step-by-step, otherwise cfdisk
2. After creating all filesystems and activating swap,
   temporarily mount root to create btrfs subvolumes:

   ```bash
   mount /dev/sda3 /mnt
   btrfs su cr /mnt/@
   btrfs su cr /mnt/@home
   btrfs su cr /mnt/@cache
   btrfs su cr /mnt/@log
   umount /mnt
   ```

3. Now, actually mount the subvolumes:

   ```bash
   mount -o subvol=/@,defaults,noatime,compress=zstd /dev/sda3 /mnt
   mount -o subvol=/@home,defaults,noatime,compress=zstd -m /dev/sda3 /mnt/home
   mount -o subvol=/@cache,defaults,noatime,compress=zstd -m /dev/sda3 /mnt/var/cache
   mount -o subvol=/@log,defaults,noatime,compress=zstd -m /dev/sda3 /mnt/var/log
   ```

4. Reflector / mirrors step:

   ```bash
   reflector \
       --country United States \
       --age 12 \
       --protocol https \
       --fastest 5 \
       --latest 20 \
       --sort rate \
       --save /etc/pacman.d/mirrorlist
   ```

   **NOTE: Remember to configure the systemd service for reflector later.**

5. Create hosts file:

   ```plaintext
   127.0.0.1 localhost
   ::1       localhost
   127.0.1.1 myhostname.localdomain myhostname
   ```

6. Before generating initramfs:

   - Add `crc32c-intel btrfs` to `MODULES=()` parentheses

After finishing the Installation Guide and Post-installation sections:

- Remove subvolid sections from fstab
- Install `snapper-support` and `btrfs-assistant` from AUR
- put `PRUNE_BIND_MOUNTS = “no”` in `/etc/updatedb.conf`,
  also add `.snapshots` to `PRUNENAMES` in that file
