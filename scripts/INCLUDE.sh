#!/bin/bash

# Output log prefixes with better color handling and backup if tput fails
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

spinner() {
  local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local colors=("\033[31m" "\033[33m" "\033[32m" "\033[36m" "\033[34m" "\033[35m" "\033[91m" "\033[92m" "\033[93m" "\033[94m")
  local spin_i=0
  local color_i=0
  local interval=0.1

  printf "\e[?25l"

  while true; do
    local color="${colors[color_i]}"
    printf "\r ${color}%s${CL}" "${frames[spin_i]}"

    spin_i=$(( (spin_i + 1) % ${#frames[@]} ))
    color_i=$(( (color_i + 1) % ${#colors[@]} ))

    sleep "$interval"
  done
}

setup_colors

format_time() {
  local total_seconds=$1
  local hours=$((total_seconds / 3600))
  local minutes=$(( (total_seconds % 3600) / 60 ))
  local seconds=$((total_seconds % 60))
  printf "%02d:%02d:%02d" $hours $minutes $seconds
}

cmdinstall() {
    local cmd="$1"
    local desc="${2:-$cmd}"

    echo -ne "${TAB}${HOLD}${INFO} ${desc}${HOLD}"
    spinner &
    SPINNER_PID=$!
    local start_time=$(date +%s)
    local output=$($cmd 2>&1)
    local exit_code=$?
    local end_time=$(date +%s)
    local elapsed_time=$((end_time - start_time))
    local formatted_time=$(format_time $elapsed_time)

    if [ $exit_code -eq 0 ]; then
        if [ -n "$SPINNER_PID" ] && ps | grep $SPINNER_PID > /dev/null; then kill $SPINNER_PID > /dev/null; fi
        printf "\e[?25h"
        echo -e "${BFR}${SUCCESS} ${desc} ${BLUE}[$formatted_time]${RESET}"
    else
        if [ -n "$SPINNER_PID" ] && ps | grep $SPINNER_PID > /dev/null; then kill $SPINNER_PID > /dev/null; fi
        printf "\e[?25h"
        echo -e "${BFR}${ERROR} ${desc} ${BLUE}[$formatted_time]${RESET}"
        echo "$output"
        exit 1
    fi
}

#================================================================================================

# Handle errors and exit
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
# Check And Install Required Dependencies
check_dependencies() {
    local dependencies=("aria2" "curl" "tar" "gzip" "unzip" "git" "wget" "sed" "grep")

    echo -e "${STEPS} Checking and installing required dependencies..."
    
    echo -e "${INFO} Updating package lists..."
    sudo apt update -qq &> /dev/null 2>&1

    for pkg in "${dependencies[@]}"; do
        if sudo dpkg -s "$pkg" &> /dev/null 2>&1; then
            echo -e "${SUCCESS} ✓ $pkg is already installed"
        else
            echo -e "${INFO} Installing $pkg..."
            
            if sudo apt-get install -y "$pkg" &> /dev/null 2>&1; then
                echo -e "${SUCCESS} ✓ $pkg installed successfully"
            else
                echo -e "${ERROR} ✗ Failed to install $pkg"
                exit 1
            fi
        fi
    done

    echo -e "${SUCCESS} Dependencies installation complete!"
}

# Aria2 Download Function
ariadl() {
    if [ "$#" -lt 1 ]; then
        echo -e "${ERROR} Usage: ariadl <URL> [OUTPUT_FILE]"
        return 1
    fi

    echo -e "${STEPS} Aria2 Downloader"

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
        echo -e "${INFO} Downloading: $URL (Attempt $((RETRY_COUNT + 1))/$MAX_RETRIES)"
        
        if [ -f "$OUTPUT_DIR/$OUTPUT_FILE" ]; then
            rm "$OUTPUT_DIR/$OUTPUT_FILE"
        fi
        
        aria2c -q -d "$OUTPUT_DIR" -o "$OUTPUT_FILE" "$URL"
        
        if [ $? -eq 0 ]; then
            echo -e "${SUCCESS} Downloaded: $OUTPUT_FILE"
            return 0
        else
            RETRY_COUNT=$((RETRY_COUNT + 1))
            if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
                echo -e "${ERROR} Download failed. Retrying..."
                sleep 2
            fi
        fi
    done

    echo -e "${ERROR} Failed to download: $OUTPUT_FILE after $MAX_RETRIES attempts"
    return 1
}

# Download external packages
download_packages() {
    local list=("${!2}") # Capture array argument
    
    if [[ $1 == "github" ]]; then
        for entry in "${list[@]}"; do
            IFS="|" read -r filename base_url <<< "$entry"
            local file_urls=$(curl -s "$base_url" | grep "browser_download_url" | grep -oE "https.*/${filename}_[_0-9a-zA-Z\._~-]*\.ipk" | sort -V | tail -n 1)
            
            if [ -z "$file_urls" ]; then
                error_msg "Failed to retrieve package info for [$filename] from $base_url"
                continue
            fi

            for file_url in $file_urls; do
                if [ -n "$file_url" ]; then
                    ariadl "$file_url" "packages/$(basename "$file_url")"
                fi
            done
        done
    elif [[ $1 == "custom" ]]; then
        for entry in "${list[@]}"; do
            IFS="|" read -r filename base_url <<< "$entry"
            
            # Array untuk menyimpan pola pencarian
            local search_patterns=(
                "\"${filename}[^\"]*\.ipk\""
                "\"${filename}[^\"]*\.apk\""
                "${filename}_.*\.ipk"
                "${filename}_.*\.apk"
                "${filename}.*\.ipk"
                "${filename}.*\.apk"
            )
            
            local file_urls=""
            local full_url=""
            
            # Coba berbagai pola pencarian
            for pattern in "${search_patterns[@]}"; do
                file_urls=$(curl -sL "$base_url" | grep -oE "$pattern" | sed 's/"//g' | sort -V | tail -n 1)
                if [ -n "$file_urls" ]; then
                    full_url="${base_url}/${file_urls%%\"*}"
                    break
                fi
            done
            
            if [ -n "$full_url" ]; then
                ariadl "$full_url" "packages/${filename}.ipk"
            else
                error_msg "No matching file found for [$filename] at $base_url"
            fi
        done
    fi
}