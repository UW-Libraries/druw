#!/usr/bin/env bash

# restore_druw.sh - restore a DRUW installation from backup
# usage: ./restore_druw.sh BACKUP
#    BACKUP: location of the file produced by backup_druw.sh

set -eu -o pipefail

BACKUP_FILE=$(basename "$1")
BACKUP_DIR="${BACKUP_FILE%.*}"
FEDORA_BASE="localhost:8984"
DRUW_BASE="localhost:3000"
REDIS_BASE="localhost:6379"
DRUW_LOC="/home/vagrant/druw"

# ensure that rails is not running
if curl -s $DRUW_BASE > /dev/null ; then
    echo "Shutdown DRUW Rails server before backing up"
    exit 1
fi

rm -rf /tmp/$BACKUP_DIR
tar -xf "$1" -C /tmp

# restore Fedora
curl -X POST -d "/tmp/$BACKUP_DIR/fedora" "http://$FEDORA_BASE/rest/fcr:restore"

# restore sqlite db
cp /tmp/$BACKUP_DIR/development.sqlite3 "$DRUW_LOC/db/"

# restore redis
if redis-cli ping > /dev/null ; then
   redis-cli shutdown > /dev/null
fi
sudo -u redis cp /tmp/$BACKUP_DIR/dump.rdb /var/lib/redis/dump.rdb
sudo chown redis:redis /var/lib/redis/dump.rdb
redis-server > /dev/null &

# restore derivatives directory
tar -xf /tmp/"$BACKUP_DIR"/derivatives.tar -C "$DRUW_LOC/tmp"

# reindex solr
cd $DRUW_LOC
bundle exec rails runner "ActiveFedora::Base.reindex_everything; exit" > /dev/null 2>&1

# cleanup
rm -r /tmp/$BACKUP_DIR

