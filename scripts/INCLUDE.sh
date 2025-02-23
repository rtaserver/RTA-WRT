#!/bin/bash

# Enable strict mode for better error handling
set -euo pipefail
IFS=$'\n\t'

# Global variables for configuration with improved type declaration
declare -A CONFIG
CONFIG=(
    ["MAX_RETRIES"]=3
    ["RETRY_DELAY"]=2
    ["SPINNER_INTERVAL"]=0.1
    ["DEBUG"]=false
)

# Cleanup function
cleanup() {
    printf "\e[?25h"  # Ensure cursor is visible
    kill $(jobs -p) 2>/dev/null || true
}

# Set up cleanup trap
trap cleanup EXIT

# Enhanced color setup with dynamic terminal capability detection
setup_colors() {
    PURPLE="\033[95m"
    BLUE="\033[94m"
    GREEN="\033[92m"
    YELLOW="\033[93m"
    RED="\033[91m"
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    RESET="\033[0m"

    STEPS="[${PURPLE} STEPS ${RESET}]"
    INFO="[${BLUE} INFO ${RESET}]"
    SUCCESS="[${GREEN} SUCCESS ${RESET}]"
    WARNING="[${YELLOW} WARNING ${RESET}]"
    ERROR="[${RED} ERROR ${RESET}]"

    # Formatting
    CL=$(echo "\033[m")
    UL=$(echo "\033[4m")
    BOLD=$(echo "\033[1m")
    BFR="\\r\\033[K"
    HOLD=" "
    TAB="  "
}

# Enhanced logging function
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%d-%m-%Y %H:%M:%S')
    
    # Output to console if not in quiet mode
    case "$level" in
        "ERROR")   echo -e "${ERROR} $message" >&2 ;;
        "STEPS")   echo -e "${STEPS} $message" ;;
        "WARNING") echo -e "${WARNING} $message" ;;
        "SUCCESS") echo -e "${SUCCESS} $message" ;;
        "INFO")    echo -e "${INFO} $message" ;;
        *)         echo -e "${INFO} $message" ;;
    esac
}

error_msg() {
    local line_number=${2:-${BASH_LINENO[0]}}
    echo -e "${ERROR} ${1} (Line: ${line_number})" >&2
    echo "Call stack:" >&2
    local frame=0
    while caller $frame; do
        ((frame++))
    done >&2
    exit 1
}

# Enhanced spinner with better process management
spinner() {
    local pid=$1
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local colors=("\033[31m" "\033[33m" "\033[32m" "\033[36m" "\033[34m" "\033[35m")
    
    printf "\e[?25l"  # Hide cursor
    
    while kill -0 $pid 2>/dev/null; do
        for ((i = 0; i < ${#frames[@]}; i++)); do
            printf "\r ${colors[i]}%s${RESET}" "${frames[i]}"
            sleep "${CONFIG[SPINNER_INTERVAL]}"
        done
    done
    
    printf "\e[?25h"  # Show cursor
    wait $pid  # Wait for process to finish and get exit status
    return $?
}

# Enhanced command installation with better error handling
cmdinstall() {
    local cmd="$1"
    local desc="${2:-$cmd}"
    
    log "INFO" "Installing: $desc"
    
    # Run command in background and capture PID
    eval "$cmd" 2>&1 &
    local cmd_pid=$!
    
    # Start spinner
    spinner $cmd_pid
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log "SUCCESS" "$desc installed successfully"
        [ "${CONFIG[DEBUG]}" = true ]
    else
        error_msg "Failed to install $desc"
        return 1
    fi
}

# Enhanced dependency checking with version comparison
check_dependencies() {
    local -A dependencies=(
        ["aria2"]="aria2c --version | grep -oP 'aria2 version \K[\d\.]+'"
        ["curl"]="curl --version | grep -oP 'curl \K[\d\.]+'"
        ["tar"]="tar --version | grep -oP 'tar \K[\d\.]+'"
        ["gzip"]="gzip --version | grep -oP 'gzip \K[\d\.]+'"
        ["unzip"]="unzip -v | grep -oP 'UnZip \K[\d\.]+'"
        ["git"]="git --version | grep -oP 'git version \K[\d\.]+'"
        ["wget"]="wget --version | grep -oP 'GNU Wget \K[\d\.]+'"
    )
    
    log "STEPS" "Checking system dependencies..."
    
    # Update package lists with error handling
    if ! sudo apt-get update -qq &>/dev/null; then
        error_msg "Failed to update package lists"
        return 1
    fi
    
    for pkg in "${!dependencies[@]}"; do
        local version_cmd="${dependencies[$pkg]}"
        local installed_version
        
        if ! installed_version=$(eval "$version_cmd" 2>/dev/null); then
            log "WARNING" "Installing $pkg..."
            if ! sudo apt-get install -y "$pkg" &>/dev/null; then
                error_msg "Failed to install $pkg"
                return 1
            fi
            installed_version=$(eval "$version_cmd")
            log "SUCCESS" "Installed $pkg version $installed_version"
        else
            log "SUCCESS" "Found $pkg version $installed_version"
        fi
    done
    
    log "SUCCESS" "All dependencies are satisfied!"
}

# Enhanced download function with retry mechanism and better error handling
ariadl() {
    if [ "$#" -lt 1 ]; then
       error_msg "Usage: ariadl <URL> [OUTPUT_FILE]"
        return 1
    fi

   log "STEPS" "Aria2 Downloader"

    local URL OUTPUT_FILE OUTPUT_DIR OUTPUT
    URL=$1
    local RETRY_COUNT=0
    local MAX_RETRIES=3

    if [ "$#" -eq 1 ]; then
        OUTPUT_FILE=$(basename "$URL")
        OUTPUT_DIR="."
    else
        OUTPUT=$2
        OUTPUT_DIR=$(dirname "$OUTPUT")
        OUTPUT_FILE=$(basename "$OUTPUT")
    fi

    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir -p "$OUTPUT_DIR"
    fi

    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
       log "INFO" "Downloading: $URL (Attempt $((RETRY_COUNT + 1))/$MAX_RETRIES)"
        
        if [ -f "$OUTPUT_DIR/$OUTPUT_FILE" ]; then
            rm "$OUTPUT_DIR/$OUTPUT_FILE"
        fi
        
        aria2c -q -d "$OUTPUT_DIR" -o "$OUTPUT_FILE" "$URL"
        
        if [ $? -eq 0 ]; then
           log "SUCCESS" "Downloaded: $OUTPUT_FILE"
            return 0
        else
            RETRY_COUNT=$((RETRY_COUNT + 1))
            if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
               error_msg " Download failed. Retrying..."
                sleep 2
            fi
        fi
    done

   error_msg " Failed to download: $OUTPUT_FILE after $MAX_RETRIES attempts"
    return 1
}

# Enhanced package downloader with improved URL handling and validation
download_packages() {
    local -n package_list="$1"  # Use nameref for array reference
    local download_dir="packages"
    
    # Create download directory
    mkdir -p "$download_dir"
    
    # Helper function for downloading
    download_file() {
        local url="$1"
        local output="$2"
        local max_retries=3
        local retry=0
        
        while [ $retry -lt $max_retries ]; do
            if ariadl "$url" "$output"; then
                return 0
            fi
            retry=$((retry + 1))
            log "WARNING" "Retry $retry/$max_retries for $output"
            sleep 2
        done
        return 1
    }

    for entry in "${package_list[@]}"; do
        IFS="|" read -r filename base_url <<< "$entry"
        unset IFS
        
        if [[ -z "$filename" || -z "$base_url" ]]; then
            error_msg "Invalid entry format: $entry"
            continue
        fi

        local download_url=""
        
        # Handling GitHub source
        if [[ "$base_url" == *"api.github.com"* ]]; then
            # Use jq to fetch asset URLs from GitHub
            if ! file_urls=$(curl -sL "$base_url" | jq -r '.assets[].browser_download_url' 2>/dev/null); then
                error_msg "Failed to parse JSON from $base_url"
                continue
            fi
            download_url=$(echo "$file_urls" | grep -E '\.(ipk|apk)$' | grep -i "$filename" | sort -V | tail -1)
        fi
        
        # Handling Custom source
        if [[ "$base_url" != *"api.github.com"* ]]; then
            # Download and process page content directly
            local page_content
            if ! page_content=$(curl -sL --max-time 30 --retry 3 --retry-delay 2 "$base_url"); then
                error_msg "Failed to fetch page: $base_url"
                continue
            fi
            
            local patterns=(
                "${filename}[^\"]*\.(ipk|apk)"
                "${filename}_.*\.(ipk|apk)"
                "${filename}.*\.(ipk|apk)"
            )
            
            for pattern in "${patterns[@]}"; do
                download_url=$(echo "$page_content" | grep -oP "(?<=\")${pattern}(?=\")" | sort -V | tail -n 1)
                if [ -n "$download_url" ]; then
                    download_url="${base_url}/${download_url}"
                    break
                fi
            done
        fi

        if [ -z "$download_url" ]; then
            error_msg "No matching package found for $filename"
            continue
        fi
        
        local output_file="$download_dir/$(basename "$download_url")"
        download_file "$download_url" "$output_file" || error_msg "Failed to download $filename"
    done
    
    return 0
}

# Initialize the script
setup_colors
main() {
    check_dependencies || exit 1
}

# Run main function if script is not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi