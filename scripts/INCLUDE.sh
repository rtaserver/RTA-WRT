#!/bin/bash

# Global variables for configuration
declare -A CONFIG=(
    ["MAX_RETRIES"]=3
    ["RETRY_DELAY"]=2
    ["SPINNER_INTERVAL"]=0.1
    ["DEBUG"]=false
)

# Enhanced color setup with fallback and terminal detection
setup_colors() {
    # Check if terminal supports colors
    if [ -t 1 ] && [ -n "$TERM" ] && [ "$TERM" != "dumb" ]; then
        PURPLE="\033[95m"
        BLUE="\033[94m"
        GREEN="\033[92m"
        YELLOW="\033[93m"
        RED="\033[91m"
        MAGENTA='\033[0;35m'
        CYAN='\033[0;36m'
        RESET="\033[0m"
    else
        # Fallback to empty strings if no color support
        PURPLE="" BLUE="" GREEN="" YELLOW="" RED="" MAGENTA="" CYAN="" RESET=""
    fi

    # Log prefixes
    readonly STEPS="[${PURPLE}STEPS${RESET}]"
    readonly INFO="[${BLUE}INFO${RESET}]"
    readonly SUCCESS="[${GREEN}SUCCESS${RESET}]"
    readonly WARNING="[${YELLOW}WARNING${RESET}]"
    readonly ERROR="[${RED}ERROR${RESET}]"

    # Formatting
    readonly CL="\033[m"
    readonly UL="\033[4m"
    readonly BOLD="\033[1m"
    readonly BFR="\\r\\033[K"
    readonly HOLD=" "
    readonly TAB="  "
}

# Enhanced spinner with cleanup trap
spinner() {
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local colors=("\033[31m" "\033[33m" "\033[32m" "\033[36m" "\033[34m" "\033[35m" "\033[91m" "\033[92m" "\033[93m" "\033[94m")
    
    # Save cursor and hide it
    printf "\e[s\e[?25l"
    
    # Ensure cursor is restored on exit
    trap 'printf "\e[u\e[?25h"' EXIT
    
    while true; do
        for ((i = 0; i < ${#frames[@]}; i++)); do
            printf "\r ${colors[i]}%s${CL}" "${frames[i]}"
            sleep "${CONFIG[SPINNER_INTERVAL]}"
        done
    done
}

# Enhanced time formatting with validation
format_time() {
    if [[ ! "$1" =~ ^[0-9]+$ ]]; then
        echo "00:00:00"
        return 1
    fi
    
    local total_seconds=$1
    local hours=$((total_seconds / 3600))
    local minutes=$(( (total_seconds % 3600) / 60 ))
    local seconds=$((total_seconds % 60))
    printf "%02d:%02d:%02d" $hours $minutes $seconds
}

# Enhanced command installation with logging and error handling
cmdinstall() {
    local cmd="$1"
    local desc="${2:-$cmd}"
    local log_file="/tmp/cmdinstall-$(date +%s).log"
    
    echo -ne "${TAB}${HOLD}${INFO} ${desc}${HOLD}"
    spinner &
    local SPINNER_PID=$!
    
    # Ensure spinner is killed on exit
    trap 'kill $SPINNER_PID 2>/dev/null' EXIT
    
    local start_time=$(date +%s)
    {
        eval "$cmd"
    } > "$log_file" 2>&1
    local exit_code=$?
    local end_time=$(date +%s)
    local elapsed_time=$((end_time - start_time))
    local formatted_time=$(format_time $elapsed_time)
    
    kill $SPINNER_PID 2>/dev/null
    printf "\e[?25h"
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${BFR}${SUCCESS} ${desc} ${BLUE}[$formatted_time]${RESET}"
        [ "${CONFIG[DEBUG]}" = true ] && cat "$log_file"
    else
        echo -e "${BFR}${ERROR} ${desc} ${BLUE}[$formatted_time]${RESET}"
        cat "$log_file"
        rm -f "$log_file"
        return 1
    fi
    
    rm -f "$log_file"
}

# Enhanced error handling with debug information
error_msg() {
    local message="$1"
    local line_number="${2:-${BASH_LINENO[0]}}"
    local stack_trace=""
    
    # Generate stack trace
    local frame=0
    while caller $frame; do
        stack_trace+="$(caller $frame)\n"
        ((frame++))
    done
    
    # Format error message
    printf "${ERROR} %s\n" "$message" >&2
    printf "Line: %s\n" "$line_number" >&2
    printf "Stack trace:\n%s" "$stack_trace" >&2
    
    return 1
}

# Enhanced dependency checking with version validation
check_dependencies() {
    local -A dependencies=(
        ["aria2"]="aria2c --version"
        ["curl"]="curl --version"
        ["tar"]="tar --version"
        ["gzip"]="gzip --version"
        ["unzip"]="unzip -v"
        ["git"]="git --version"
        ["wget"]="wget --version"
        ["sed"]="sed --version"
        ["grep"]="grep --version"
    )
    
    echo -e "${STEPS} Checking system dependencies..."
    
    # Update package lists quietly
    if ! sudo apt-get update -qq &>/dev/null; then
        error_msg "Failed to update package lists"
        return 1
    fi
    
    for pkg in "${!dependencies[@]}"; do
        echo -ne "${INFO} Checking $pkg... "
        
        if command -v "$pkg" &>/dev/null && eval "${dependencies[$pkg]}" &>/dev/null; then
            echo -e "${SUCCESS} ✓"
        else
            echo -e "${WARNING} Installing..."
            if ! sudo apt-get install -y "$pkg" &>/dev/null; then
                error_msg "Failed to install $pkg"
                return 1
            fi
            echo -e "${SUCCESS} ✓ Installed successfully"
        fi
    done
    
    echo -e "${SUCCESS} All dependencies are satisfied!"
}

# Enhanced download function with better error handling and progress tracking
ariadl() {
    local url="$1"
    local output="${2:-$(basename "$url")}"
    local output_dir="$(dirname "$output")"
    local retry_count=0
    
    # Validate URL
    if ! curl --output /dev/null --silent --head --fail "$url"; then
        error_msg "Invalid URL: $url"
        return 1
    fi
    
    # Create output directory if it doesn't exist
    mkdir -p "$output_dir" || {
        error_msg "Failed to create output directory: $output_dir"
        return 1
    }
    
    echo -e "${STEPS} Downloading ${url##*/}..."
    
    while [ $retry_count -lt "${CONFIG[MAX_RETRIES]}" ]; do
        echo -e "${INFO} Attempt $((retry_count + 1))/${CONFIG[MAX_RETRIES]}"
        
        if aria2c --quiet \
                 --max-tries=3 \
                 --retry-wait=3 \
                 --dir="$output_dir" \
                 --out="$(basename "$output")" \
                 --continue=true \
                 "$url"; then
            echo -e "${SUCCESS} Download complete: ${output##*/}"
            return 0
        fi
        
        ((retry_count++))
        [ $retry_count -lt "${CONFIG[MAX_RETRIES]}" ] && {
            echo -e "${WARNING} Retrying in ${CONFIG[RETRY_DELAY]} seconds..."
            sleep "${CONFIG[RETRY_DELAY]}"
        }
    done
    
    error_msg "Failed to download after ${CONFIG[MAX_RETRIES]} attempts: ${url##*/}"
    return 1
}

# Enhanced package downloader with better URL handling and validation
download_packages() {
    local source="$1"
    shift
    local -a package_list=("$@")
    
    echo -e "${STEPS} Downloading packages from $source..."
    mkdir -p packages
    
    case "$source" in
        github)
            for entry in "${package_list[@]}"; do
                IFS="|" read -r filename base_url <<< "$entry"
                
                local latest_url=$(curl -s "$base_url" | \
                                 grep -oE "https.*/${filename}_[_0-9a-zA-Z\._~-]*\.ipk" | \
                                 sort -V | tail -n 1)
                
                if [ -n "$latest_url" ]; then
                    ariadl "$latest_url" "packages/$(basename "$latest_url")"
                else
                    error_msg "No matching package found: $filename"
                fi
            done
            ;;
            
        custom)
            for entry in "${package_list[@]}"; do
                IFS="|" read -r filename base_url <<< "$entry"
                
                local patterns=(
                    "${filename}[^\"]*\.(ipk|apk)"
                    "${filename}_.*\.(ipk|apk)"
                    "${filename}.*\.(ipk|apk)"
                )
                
                local found_url=""
                for pattern in "${patterns[@]}"; do
                    found_url=$(curl -sL "$base_url" | \
                              grep -oE "\"$pattern\"" | \
                              sed 's/"//g' | \
                              sort -V | \
                              tail -n 1)
                    
                    if [ -n "$found_url" ]; then
                        ariadl "${base_url}/${found_url}" "packages/${filename}.ipk"
                        break
                    fi
                done
                
                [ -z "$found_url" ] && error_msg "No matching file found: $filename"
            done
            ;;
            
        *)
            error_msg "Invalid source: $source"
            return 1
            ;;
    esac
}

# Initialize the script
setup_colors
