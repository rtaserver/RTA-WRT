#!/bin/bash

. ./scripts/INCLUDE.sh

build_mod_sdcard() {
    local image_path="$1"
    local dtb="$2"
    local suffix="$3"

    log "STEPS" "Modifying boot files for Amlogic s905x devices..."
    
    # Validate input parameters
    if [ -z "$suffix" ] || [ -z "$dtb" ] || [ -z "$image_path" ]; then
        error_msg "Missing required parameters. Usage: build_mod_sdcard <image_path> <dtb> <image_suffix>"
        return 1
    fi

    # Validate and set paths
    if ! cd "$GITHUB_WORKSPACE/$WORKING_DIR/compiled_images"; then
        error_msg "Failed to change directory to $GITHUB_WORKSPACE/$WORKING_DIR/compiled_images"
        return 1
    fi

    local imgpath="$GITHUB_WORKSPACE/$WORKING_DIR/compiled_images"
    local file_to_process="$image_path"

    cleanup() {
        log "INFO" "Cleaning up temporary files..."
        sudo umount boot 2>/dev/null || true
        sudo losetup -D 2>/dev/null || true
    }

    trap cleanup EXIT

    if [ -z "$file_to_process" ] || [ ! -f "$file_to_process" ]; then
        error_msg "Image file not found: ${file_to_process}"
        return 1
    fi

    # Download modification files
    ariadl "https://github.com/rizkikotet-dev/mod-boot-sdcard/archive/refs/heads/main.zip" "main.zip"

    # Extract files
    log "INFO" "Extracting mod-boot-sdcard..."
    if ! unzip -q main.zip; then
        error_msg "Failed to extract mod-boot-sdcard"
        return 1
    fi
    rm -f main.zip
    log "SUCCESS" "mod-boot-sdcard successfully extracted."
    sleep 3

    # Create working directory
    mkdir -p "${suffix}/boot"
    
    # Copy required files
    log "INFO" "Preparing image for ${suffix}..."
    cp "$file_to_process" "${suffix}/"
    if ! sudo cp mod-boot-sdcard-main/BootCardMaker/u-boot.bin \
        mod-boot-sdcard-main/files/mod-boot-sdcard.tar.gz "${suffix}/"; then
        error_msg "Failed to copy bootloader or modification files"
        return 1
    fi

    # Process the image
    cd "${suffix}" || {
        error_msg "Failed to change directory to ${suffix}"
        return 1
    }

    local file_name=$(basename "${file_to_process%.gz}")

    # Decompress the OpenWRT image
    if ! sudo gunzip "${file_name}.gz"; then
        error_msg "Failed to decompress image"
        return 1
    fi

    # Set up loop device
    local device
    log "INFO" "Setting up loop device..."
    for i in {1..3}; do
        device=$(sudo losetup -fP --show "${file_name}" 2>/dev/null)
        [ -n "$device" ] && break
        sleep 1
    done

    if [ -z "$device" ]; then
        error_msg "Failed to set up loop device"
        return 1
    fi

    # Mount the image
    log "INFO" "Mounting the image..."
    local attempts=0
    while [ $attempts -lt 3 ]; do
        if sudo mount "${device}p1" boot; then
            break
        fi
        attempts=$((attempts + 1))
        sleep 1
    done

    if [ $attempts -eq 3 ]; then
        error_msg "Failed to mount image"
        return 1
    fi

    # Apply modifications
    log "INFO" "Applying boot modifications..."
    if ! sudo tar -xzf mod-boot-sdcard.tar.gz -C boot; then
        error_msg "Failed to extract boot modifications"
        return 1
    fi

    # Update configuration files
    log "INFO" "Updating configuration files..."
    local uenv=$(sudo cat boot/uEnv.txt | grep APPEND | awk -F "root=" '{print $2}')
    local extlinux=$(sudo cat boot/extlinux/extlinux.conf | grep append | awk -F "root=" '{print $2}')
    local boot=$(sudo cat boot/boot.ini | grep dtb | awk -F "/" '{print $4}' | cut -d'"' -f1)

    sudo sed -i "s|$extlinux|$uenv|g" boot/extlinux/extlinux.conf
    sudo sed -i "s|$boot|$dtb|g" boot/boot.ini
    sudo sed -i "s|$boot|$dtb|g" boot/extlinux/extlinux.conf
    sudo sed -i "s|$boot|$dtb|g" boot/uEnv.txt

    sync
    sudo umount boot

    # Write bootloader
    log "INFO" "Writing bootloader..."
    if ! sudo dd if=u-boot.bin of="${device}" bs=1 count=444 conv=fsync 2>/dev/null || \
       ! sudo dd if=u-boot.bin of="${device}" bs=512 skip=1 seek=1 conv=fsync 2>/dev/null; then
        error_msg "Failed to write bootloader"
        return 1
    fi

    # Detach loop device and compress
    sudo losetup -d "${device}"
    if ! sudo gzip "${file_name}"; then
        error_msg "Failed to compress image"
        return 1
    fi

    if [ -f "../${file_name}.gz" ]; then
        rm -rf "../${file_name}.gz"
    fi

    local kernel
    kernel=$(grep -oP 'k[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9-]+)?' <<<"${file_name}")
    local new_name="RTA-WRT-${OP_BASE}-${BRANCH}-Amlogic_s905X-${suffix}-${kernel}.img.gz"

    mv "${file_name}.gz" "../${new_name}" || {
        error_msg "Failed to rename image file"
        return 1
    }

    cd ..
    rm -rf "${suffix}"
    rm -rf mod-boot-sdcard-main
    cleanup
    log "SUCCESS" "Successfully processed ${suffix}"
    return 0
}

process_builds() {
    local img_dir="$1"
    local builds=("${@:2}")
    local exit_code=0
    
    # Process builds based on tunnel mode
    for build in "${builds[@]}"; do
        IFS=: read -r device dtb model <<< "$build"
        local image_file=$(find "$img_dir" -name "*${device}*.img.gz")
        
        if [[ -n "$image_file" ]]; then
            if ! build_mod_sdcard "$image_file" "$dtb" "$model"; then
                error_msg "Failed to process build for $model ($device)"
                exit_code=1
            fi
        else
            log "WARNING" "No image file found for $model ($device)"
        fi
    done
    
    return $exit_code
}

main() {
    local exit_code=0
    local img_dir="$GITHUB_WORKSPACE/$WORKING_DIR/compiled_images"
    
    # Configuration array with format device:dtb:model
    local builds=()
    case $MATRIXTARGET in
        "Amlogic s905X HG680P")
            builds=(
                "_s905x_k5:meson-gxl-s905x-p212.dtb:HG680P"
                "_s905x_k6:meson-gxl-s905x-p212.dtb:HG680P"
                "-s905x-:meson-gxl-s905x-p212.dtb:HG680P"
            )
            ;;
        "Amlogic s905X B860H")
            builds=(
                "_s905x-b860h_k5:meson-gxl-s905x-b860h.dtb:B860H_v1-v2"
                "_s905x-b860h_k6:meson-gxl-s905x-b860h.dtb:B860H_v1-v2"
                "-s905x-:meson-gxl-s905x-b860h.dtb:B860H_v1-v2"
            )
            ;;
    esac
    
    # Validate environment
    if [[ ! -d "$img_dir" ]]; then
        error_msg "Image directory not found: $img_dir"
        return 1
    fi
    
    # Process builds
    if ! process_builds "$img_dir" "${builds[@]}"; then
        exit_code=1
    fi
    
    return $exit_code
}

# Execute main function
main