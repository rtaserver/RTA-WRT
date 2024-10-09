#!/bin/bash
# Copyrigth Mutiara-WRt by @Maizil

# Konfigurasi koneksi database
DB_USER="radius"
DB_PASS="radius"
DB_NAME="radius"
DB_HOST="127.0.0.1"

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 TERMINATE_CAUSE MAC_ADDRESS TIMESTAMP"
    exit 1
fi

LOG_FILE="/var/log/radius.log"
USERNAME=$1
TERMINATE_CAUSE=$2
MAC_ADDRESS=$3
TIMESTAMP=$(date '+%a %b  %-d %T %Y')

get_last_session_info() {
    grep "Login OK" "$LOG_FILE" | grep "cli $MAC_ADDRESS" | tail -n 1 | sed -n 's/.*Auth: (\([0-9]*\)) Login OK:.*(from client localhost port \([0-9]*\) cli .*/\1 \2/p'
}

read LAST_SESSION_NUMBER LAST_PORT <<< $(get_last_session_info)

if [ -z "$LAST_SESSION_NUMBER" ]; then
    SESSION_NUMBER=1
else
    SESSION_NUMBER=$((LAST_SESSION_NUMBER + 1))
fi

echo "$TIMESTAMP : Auth: ($SESSION_NUMBER) LogOut OK: [$USERNAME/$TERMINATE_CAUSE] (from client localhost port $LAST_PORT cli $MAC_ADDRESS)" >> "$LOG_FILE"

