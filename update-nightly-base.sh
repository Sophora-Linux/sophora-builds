#!/bin/bash

# Chemin vers le dossier de construction
BUILD_DIR="/home/almalinux/builds/base/"

# Chemin vers le chroot
CHROOT_DIR="${BUILD_DIR}"

# Format de la date pour le nom de l'archive
DATE_FORMAT=$(date +"%Y%m%d%H%M")

# Chemin vers la nouvelle archive
NEW_ARCHIVE="/var/www/html/sophora/builds/sophora-base-openrc-${DATE_FORMAT}.tar.xz"

# URL du webhook Discord
DISCORD_WEBHOOK_URL="xxxx"

# Monter les systèmes de fichiers virtuels
mount -t proc /proc "${CHROOT_DIR}/proc"
mount --rbind /sys "${CHROOT_DIR}/sys"
mount --rbind /dev "${CHROOT_DIR}/dev"

# Chroot dans le dossier et exécuter les commandes de mise à jour
chroot "${CHROOT_DIR}" /bin/bash -c "eix-sync && emerge --sync && emerge -vuDN @world && rm -rf /var/cache/distfiles/* && history -c && exit"

# Sortir du chroot et démonter les systèmes de fichiers virtuels
umount -Rl "${CHROOT_DIR}dev"
umount -Rl "${CHROOT_DIR}proc"
umount -Rl "${CHROOT_DIR}sys"

# Créer une nouvelle archive avec le nom basé sur la date
tar -cJvf "${NEW_ARCHIVE}" -C "${BUILD_DIR}" .

# Notification de création sur le serveur Discord Sophora
curl -X POST -H "Content-Type: application/json" -d "{\"content\": \"${NEW_ARCHIVE##*/}\"}" "${DISCORD_WEBHOOK_URL}"