#!/bin/bash

. ./scripts/INCLUDE.sh

build_mod_sdcard() {
    local image_path="$1"
    local dtb="$2"
    local suffix="$3"

    echo -e "${STEPS} Modifying boot files for Amlogic s905x devices..."
    
    # Validate input parameters
    if [ -z "$suffix" ] || [ -z "$dtb" ] || [ -z "$image_path" ]; then
        echo -e "${ERROR} Missing required parameters. Usage: build_mod_sdcard <image_path> <dtb> <image_suffix>"
        return 1
    fi

    # Validate and set paths
    if ! cd "$GITHUB_WORKSPACE/$WORKING_DIR/compiled_images"; then
        echo -e "${ERROR} Failed to change directory to $GITHUB_WORKSPACE/$WORKING_DIR/compiled_images"
        return 1
    fi

    local imgpath="$GITHUB_WORKSPACE/$WORKING_DIR/compiled_images"
    local file_to_process="$image_path"

    cleanup() {
        echo -e "${INFO} Cleaning up temporary files..."
        sudo umount boot 2>/dev/null || true
        sudo losetup -D 2>/dev/null || true
    }

    trap cleanup EXIT

    if [ -z "$file_to_process" ] || [ ! -f "$file_to_process" ]; then
        echo -e "${ERROR} Image file not found: ${file_to_process}"
        return 1
    fi

    # Download modification files
    ariadl "https://github.com/rizkikotet-dev/mod-boot-sdcard/archive/refs/heads/main.zip" "main.zip"

    # Extract files
    echo -e "${INFO} Extracting mod-boot-sdcard..."
    if ! unzip -q main.zip; then
        echo -e "${ERROR} Failed to extract mod-boot-sdcard"
        return 1
    fi
    rm -f main.zip
    echo -e "${SUCCESS} mod-boot-sdcard successfully extracted."
    sleep 3

    # Create working directory
    mkdir -p "${suffix}/boot"
    
    # Copy required files
    echo -e "${INFO} Preparing image for ${suffix}..."
    cp "$file_to_process" "${suffix}/"
    if ! sudo cp mod-boot-sdcard-main/BootCardMaker/u-boot.bin \
        mod-boot-sdcard-main/files/mod-boot-sdcard.tar.gz "${suffix}/"; then
        echo -e "${ERROR} Failed to copy bootloader or modification files"
        return 1
    fi

    # Process the image
    cd "${suffix}" || {
        echo -e "${ERROR} Failed to change directory to ${suffix}"
        return 1
    }

    local file_name=$(basename "${file_to_process%.gz}")

    # Decompress the OpenWRT image
    if ! sudo gunzip "${file_name}.gz"; then
        echo -e "${ERROR} Failed to decompress image"
        return 1
    fi

    # Set up loop device
    local device
    echo -e "${INFO} Setting up loop device..."
    for i in {1..3}; do
        device=$(sudo losetup -fP --show "${file_name}" 2>/dev/null)
        [ -n "$device" ] && break
        sleep 1
    done

    if [ -z "$device" ]; then
        echo -e "${ERROR} Failed to set up loop device"
        return 1
    fi

    # Mount the image
    echo -e "${INFO} Mounting the image..."
    local attempts=0
    while [ $attempts -lt 3 ]; do
        if sudo mount "${device}p1" boot; then
            break
        fi
        attempts=$((attempts + 1))
        sleep 1
    done

    if [ $attempts -eq 3 ]; then
        echo -e "${ERROR} Failed to mount image"
        return 1
    fi

    # Apply modifications
    echo -e "${INFO} Applying boot modifications..."
    if ! sudo tar -xzf mod-boot-sdcard.tar.gz -C boot; then
        echo -e "${ERROR} Failed to extract boot modifications"
        return 1
    fi

    # Update configuration files
    echo -e "${INFO} Updating configuration files..."
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
    echo -e "${INFO} Writing bootloader..."
    if ! sudo dd if=u-boot.bin of="${device}" bs=1 count=444 conv=fsync 2>/dev/null || \
       ! sudo dd if=u-boot.bin of="${device}" bs=512 skip=1 seek=1 conv=fsync 2>/dev/null; then
        echo -e "${ERROR} Failed to write bootloader"
        return 1
    fi

    # Detach loop device and compress
    sudo losetup -d "${device}"
    if ! sudo gzip "${file_name}"; then
        echo -e "${ERROR} Failed to compress image"
        return 1
    fi

    if -f "../${file_name}.gz"; then
        rm -rf "../${file_name}.gz"
    fi
    mv "${file_name}.gz" "../${file_name}.gz" || {
        echo -e "${ERROR} Failed to rename image file"
        return 1
    }

    cd ..
    rm -rf "${suffix}"
    rm -rf mod-boot-sdcard-main
    cleanup
    echo -e "${SUCCESS} Successfully processed ${suffix}"
    return 0
}

# Main execution
main() {
    local exit_code=0
    
    # Process HG680P images
    build_mod_sdcard "$(find ""$GITHUB_WORKSPACE/$WORKING_DIR/compiled_images" -name "*_s905x_k5.15*.img.gz")" "meson-gxl-s905x-p212.dtb" "HG680P"
    build_mod_sdcard "$(find ""$GITHUB_WORKSPACE/$WORKING_DIR/compiled_images" -name "*_s905x_k6.6*.img.gz")" "meson-gxl-s905x-p212.dtb" "HG680P"

    # Process B860H v1/v2 images
    build_mod_sdcard "$(find ""$GITHUB_WORKSPACE/$WORKING_DIR/compiled_images" -name "*_s905x-b860h_k5.15*.img.gz")" "meson-gxl-s905x-b860h.dtb" "B860H_v1-v2"
    build_mod_sdcard "$(find ""$GITHUB_WORKSPACE/$WORKING_DIR/compiled_images" -name "*_s905x-b860h_k6.6*.img.gz")" "meson-gxl-s905x-b860h.dtb" "B860H_v1-v2"

    return $exit_code
}

main
