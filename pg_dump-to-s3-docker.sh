#!/usr/bin/env bash

#                     _                             _                  _____ 
#  _ __   __ _     __| |_   _ _ __ ___  _ __       | |_ ___        ___|___ / 
# | '_ \ / _` |   / _` | | | | '_ ` _ \| '_ \ _____| __/ _ \ _____/ __| |_ \ 
# | |_) | (_| |  | (_| | |_| | | | | | | |_) |_____| || (_) |_____\__ \___) |
# | .__/ \__, |___\__,_|\__,_|_| |_| |_| .__/       \__\___/      |___/____/ 
# |_|    |___/_____|                   |_|                                   
#
# Project at https://github.com/gabfl/pg_dump-to-s3
#

set -e

# Set current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Import config file
if [ -f "${HOME}/.pg_dump-to-s3.conf" ]; then
    source ${HOME}/.pg_dump-to-s3.conf
else
    source $DIR/.conf
fi

# Vars
NOW=$(date +"%Y-%m-%d-at-%H-%M-%S")
DELETETION_TIMESTAMP=`[ "$(uname)" = Linux ] && date +%s --date="-$DELETE_AFTER"` # Maximum date (will delete all files older than this date)

# Split databases
IFS=',' read -ra DBS <<< "$PG_DATABASES"

# Delete old files
echo " * Backup in progress.,.";

# Loop thru databases
for db in "${DBS[@]}"; do
    FILENAME="$NOW"_"$db"


    echo "   -> backing up $db..."

    # Dump database
    pg_dump -Fc -h $PG_HOST -U $PG_USER -p $PG_PORT $db > /tmp/"$FILENAME".dump

    # Log
    echo "      ...database $db has been backed up inside container"
done

echo ""
echo "...done!";
echo ""
