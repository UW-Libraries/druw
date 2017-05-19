#!/usr/bin/env bash

# backup_druw.sh - back up the DRUW installation
# usage: ./backup_druw.sh
# yields a backup file in /tmp: druw-backup.tar

set -eu -o pipefail

FEDORA_BASE="localhost:8984"
DRUW_BASE="localhost:3000"
DRUW_LOC="/home/vagrant/druw"
BACKUP_PATH="/tmp/druw-backup"

# ensure that rails is not running
if curl -s $DRUW_BASE > /dev/null ; then
   echo "Shutdown DRUW Rails server before backing up"
   exit 1
fi

rm -rf "$BACKUP_PATH"
mkdir -p "$BACKUP_PATH"

# backup fedora
backup_location=$(curl -s -X POST http://$FEDORA_BASE/rest/fcr:backup)
mv $backup_location /tmp/druw-backup/fedora

# backup sqlite db
cp "$DRUW_LOC/db/development.sqlite3" "$BACKUP_PATH"/

# backup derivatives directory
tar -cf "$BACKUP_PATH"/derivatives.tar -C "$DRUW_LOC/tmp" derivatives 

# backup redis
cp /var/lib/redis/dump.rdb "$BACKUP_PATH"/

# create tar file & cleanup
tar -cf /tmp/druw-backup.tar -C /tmp druw-backup
rm -r "$BACKUP_PATH"/
