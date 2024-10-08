# Arch

To have the GUI of another computer to aid with install:

1. Boot installation media
2. Set root password via `passwd`
3. Do `PermitRootLogin yes` in `etc/ssh/sshd_config`
4. `systemctl start sshd`
5. Get IP via `ip addr`
6. ssh via other machine

## Installation Guide

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

## Post-Install

Prioritize the following first:

- Create new user
- Ensure proprietary graphics
- Install and configure:
  - audio
  - desktop environment
  - web browser

Reboot into desktop environment as regular user
and complete remaining post-installation sections on the wiki.

## Snapper

1. Remove subvolid sections from fstab
2. Install `snapper-support` and `btrfs-assistant` from AUR
3. put `PRUNE_BIND_MOUNTS = “no”` in `/etc/updatedb.conf`,
   also add `.snapshots` to `PRUNENAMES` in that file
4. Regenerate initramfs

After all sections above are complete, run arch.sh
