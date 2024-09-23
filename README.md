# bootstrap

Welcome to Flavortown

## Debian

`bash <(curl -s https://raw.githubusercontent.com/cgwhouse/bootstrap/refs/heads/bootstrap2/bootstrap2.sh)`

1. Install via net installer, deselect all tasks for minimal installation
2. If we need newer packages than current stable:
   - [Update apt sources to Testing](https://wiki.debian.org/DebianTesting)
   - [Add Unstable packages with lower priority](https://wiki.debian.org/DebianUnstable)
   - Update system and reboot
3. Install git and clone this repo
4. Set optional flag in debian.sh:
   - If headless environment is intended: `server=true`
5. Run debian.sh
6. Move bootstrap directory to repos
7. Reboot

## Gentoo

1. Follow the Handbook.
   When it says to reboot, before doing so, install and configure eix.
2. After completing the Handbook, do the following in order using Gentoo Wiki:
   - desktop environment (`vaapi vdpau -gnome-online-accounts -kde -plasma -telemetry`)
   - audio (`pipewire`)
   - web browser
3. After installing and spot-checking the above items, clone this repo
4. Run gentoo.sh

## Tumbleweed

1. Install via ISO
2. Configure zypper concurrent connections and download speed:

   ```text
   download.max_concurrent_connections=10
   download.min_download_speed=20000
   ```

3. Install codecs and update system for good measure:

   ```bash
   sudo zypper install codecs
   opi codecs
   sudo zypper refresh
   sudo zypper dup --allow-vendor-change
   ```

4. Install git and clone this repo
5. Run tw.sh
6. Move bootstrap directory to repos
7. Reboot

## Fedora

1. Install via ISO of desired desktop environment
2. Configure dnf parallel downloads and fastest mirror:

   ```text
   max_parallel_downloads=10
   fastestmirror=True
   ```

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

## Arch

To have the GUI of another computer to aid with install:

1. Boot installation media
2. Set root password via `passwd`
3. Do `PermitRootLogin yes` in `etc/ssh/sshd_config`
4. `systemctl start sshd`
5. Get IP via `ip addr`
6. ssh via other machine

### Installation Guide

Follow the Installation Guide on the wiki.

1. After creating all filesystems and activating swap,
   temporarily mount root to create btrfs subvolumes:

   ```bash
   mount /dev/sda3 /mnt
   btrfs su cr /mnt/@
   btrfs su cr /mnt/@home
   btrfs su cr /mnt/@cache
   btrfs su cr /mnt/@log
   umount /mnt
   ```

2. Now, actually mount the subvolumes:

   ```bash
   mount -o subvol=/@,defaults,noatime,compress=zstd /dev/sda3 /mnt
   mount -o subvol=/@home,defaults,noatime,compress=zstd -m /dev/sda3 /mnt/home
   mount -o subvol=/@cache,defaults,noatime,compress=zstd -m /dev/sda3 /mnt/var/cache
   mount -o subvol=/@log,defaults,noatime,compress=zstd -m /dev/sda3 /mnt/var/log
   ```

3. Reflector / mirrors step:

   ```bash
   reflector \
       --country "United States" \
       --age 12 \
       --protocol https \
       --fastest 5 \
       --latest 20 \
       --sort rate \
       --save /etc/pacman.d/mirrorlist
   ```

   **NOTE: Remember to configure the systemd service for reflector later.**

4. Create hosts file:

   ```plaintext
   127.0.0.1 localhost
   ::1       localhost
   127.0.1.1 myhostname.localdomain myhostname
   ```

5. Before generating initramfs:

   - Add `crc32c-intel btrfs` to `MODULES=()` parentheses

### Post-Install

Prioritize the following first:

- Create new user
- Ensure proprietary graphics
- Install and configure:
  - audio
  - desktop environment
  - web browser

Reboot into desktop environment as regular user
and complete remaining post-installation sections on the wiki.

### Snapper

1. Remove subvolid sections from fstab
2. Install `snapper-support` and `btrfs-assistant` from AUR
3. put `PRUNE_BIND_MOUNTS = “no”` in `/etc/updatedb.conf`,
   also add `.snapshots` to `PRUNENAMES` in that file
4. Regenerate initramfs

After all sections above are complete, run arch.sh
