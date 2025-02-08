#!/bin/bash

# Load credentials from credential.txt
if [[ ! -f "credential.txt" ]]; then
    echo "❌ Error: credential.txt file not found!" >&2
    exit 1
fi

# Read credentials
source credential.txt

# Error handling
set -euo pipefail

# Constants
readonly MAX_RETRIES=5
readonly RETRY_DELAY=2
CACHE_DIR="/tmp/telegram_cache"

# Create cache directory if it doesn't exist
mkdir -p "$CACHE_DIR"

# Helper function for error handling
handle_error() {
    echo "❌ Error: $1" >&2
    exit 1
}

# Function to send Telegram message
send_telegram_message() {
    local message="$1"
    local parse_mode="${2:-Markdown}"
    
    local response
    response=$(curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" \
        -d "parse_mode=$parse_mode" \
        -d "text=$message") || handle_error "Failed to send Telegram message"
    
    echo "$response"
}

cache_message() {
    local message_id="$1"
    local message_content="$2"
    echo "$message_content" > "$CACHE_DIR/message_${message_id}.txt"
}

get_cached_message() {
    local message_id="$1"
    local cache_file="$CACHE_DIR/message_${message_id}.txt"
    
    if [[ -f "$cache_file" ]]; then
        cat "$cache_file"
        return 0
    fi
    return 1
}

generate_message() {
    local devices_json="$1"
    local devices
    
    if ! readarray -t devices < <(echo "$devices_json" | jq -r '.[]'); then
        handle_error "Failed to parse devices JSON"
    fi
    
    # Create message with proper escaping
    local message
    message=$(cat << EOF
=======================
🚀 *RTA-WRT | Build Status*
=======================
📌 *Version*: 1.0
🌿 *Branch*: Main
📅 *Date*: $(date '+%d-%m-%Y %H:%M:%S')
-----------------------
📋 *Device List*
EOF
)

    # Add devices to message
    for device in "${devices[@]}"; do
        message+=$'\n'"🔹 $device | ⏳ Pending"
    done
    
    message+=$'\n'"======================="
    
    local telegram_message="${message//$'\n'/%0A}"
    
    local response
    response=$(send_telegram_message "$telegram_message")
    
    local message_id
    message_id=$(echo "$response" | jq -r '.result.message_id')
    
    if [[ "$message_id" == "null" || -z "$message_id" ]]; then
        handle_error "Failed to get message ID"
    fi
    
    cache_message "$message_id" "$message"
    
    echo "$message_id"
}

update_status() {
    local message_id="$1"
    local devices_json="$2"
    local device="$3"
    local status="$4"
    
    [[ -z "$message_id" || -z "$devices_json" || -z "$device" || -z "$status" ]] && \
        handle_error "Missing required parameters\nUsage: $0 --update <message_id> <devices_json> <device> <status>"
    
    local current_message
    current_message=$(get_cached_message "$message_id") || \
        handle_error "Failed to retrieve cached message content"
    
    local updated_message
    updated_message=$(echo "$current_message" | sed "s/🔹 $device |.*$/🔹 $device | $status/")
    
    cache_message "$message_id" "$updated_message"
    
    local telegram_message="${updated_message//$'\n'/%0A}"
    
    local edit_response
    edit_response=$(curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/editMessageText" \
        -d "chat_id=$CHAT_ID" \
        -d "message_id=$message_id" \
        -d "parse_mode=Markdown" \
        -d "text=$telegram_message") || \
        handle_error "Failed to update message"
    
    echo "✅ Status for '$device' updated to '$status'"
}

# Main script
main() {
    case $1 in
        --generate)
            [[ -z "$2" ]] && handle_error "Missing devices_json parameter\nUsage: $0 --generate <devices_json>"
            generate_message "$2"
            ;;
        --update)
            [[ $# -lt 5 ]] && handle_error "Missing parameters\nUsage: $0 --update <message_id> <devices_json> <device> <status>"
            update_status "$2" "$3" "$4" "$5"
            ;;
        *)
            echo "Usage: $0 --generate <devices_json>"
            echo "       $0 --update <message_id> <devices_json> <device> <status>"
            exit 1
            ;;
    esac
}

main "$@"