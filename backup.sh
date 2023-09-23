#!/bin/bash

# Variables
GPG_PASSWORD=
FTP_HOST=
FTP_USERNAME=
FTP_PASSWORD=

echo "Start backup of Mastodon instance $(hostname) at $(date)"

# Create temp backup directory
mkdir -p /var/tmp/backups/$(date +%d-%m-%Y)

# Dump PostgreSQL database
echo "Dump PostgreSQL Database"
docker exec -it mastodon-db-1 pg_dump -U postgres postgres | gzip -9 > /var/tmp/backups/$(date +%d-%m-%Y)/dbdump-mastodon-$(date +%d-%m-%Y).sql

# Backup docker-compose file and relevant configuration
tar cfP /var/tmp/backups/$(date +%d-%m-%Y)/docker-config.tgz /opt/mastodon/docker-compose.yml /opt/mastodon/.env.db /opt/mastodon/.env.es /opt/mastodon/.env.mastodon 2>&1 > /dev/null

# Backup redis kv-store
tar cfP /var/tmp/backups/$(date +%d-%m-%Y)/redis.tgz /opt/mastodon/data/redis/dump.rdb 2>&1 > /dev/null

# Pack everything into a single file and encrypt it
tar cfP /var/tmp/backups/burningboard.net-$(date +%d-%m-%Y).tgz /var/tmp/backups/$(date +%d-%m-%Y) 2>&1 > /dev/null
echo "Encrypt Backup with GPG and Passphrase into burningboard.net-$(date +%d-%m-%Y).tgz"
echo ${GPG_PASSWORD} | gpg --batch --yes --passphrase-fd 0 -c /var/tmp/backups/burningboard.net-$(date +%d-%m-%Y).tgz

# Upload encrypted file to ftp server
echo "Start Backuop FTP Upload to ${FTP_HOST}".gpg
curl --netrc --upload-file /var/tmp/backups/burningboard.net-$(date +%d-%m-%Y).tgz.gpg ftp://${FTP_USERNAME}:${FTP_PASSWORD}@${FTP_HOST}/

# Clean everything up
echo "Cleanup local backup files"
rm -rf /var/tmp/backups

echo "Mastodon Backup finished at $(date)" 
