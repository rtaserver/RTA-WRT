#!/bin/sh
# Created by Frizkyiman
# Github https://github.com/frizkyiman/

modem_info=$(mmcli -L | awk -F']' '/Modem/{print $2}' | sed 's/^[ \t]*//')
modem_id=$(mmcli -L | awk -F'/Modem/' 'NF>1{print $2; exit}' | awk '{print $1}')
sms_list=$(mmcli -m "$modem_id" --messaging-list-sms)

log_file="/root/sms_message.log"
max_file_size=524288 #0.5MB

if [ "$(mmcli -L)" == "No modems were found" ]; then
    echo "Error: Modem not found."
    exit 1
elif [ "$sms_list" = "No sms messages were found" ]; then
    echo "No SMS messages were found from modem [$modem_info]"
    exit 0
else
    echo "SMS received from modem [$modem_info]"
    echo "SMS Message list:"
    echo "$sms_list"

    echo "$sms_list" | while IFS= read -r sms_info; do
        sms_id=$(echo "$sms_info" | awk -F'/SMS/' 'NF>1{print $2}' | awk '{print $1}')
        message=$(mmcli -m "$modem_id" --sms "$sms_id")
        if [ -n "$message" ]; then
            echo "$message" | tee temp_message.log
            cat "$log_file" >> temp_message.log && mv temp_message.log "$log_file"
        fi
    done
fi

file_size=$(ls -l "$log_file" | awk '{print $5}')
if [ "$file_size" -gt "$max_file_size" ]; then
    rm "$log_file" && touch "$log_file"
fi
