modsdcard() {
    local TargetIMG=$1
    local TargetFw=$2
    local Prefix=$3
    local DTBName=$4

    echo -e "${STEPS} Modifying boot files for Amlogic s905x devices..."
    
    # Validate and change directory with error handling
    if ! cd "${imagebuilder_path}/out_firmware"; then
        error_msg "Failed to change directory to ${imagebuilder_path}/out_firmware"
    fi

    # Download and extract with better error handling
    echo -e "${INFO} Downloading mod-boot-sdcard..."
    if ! curl -fsSLO https://github.com/rizkikotet-dev/mod-boot-sdcard/archive/refs/heads/main.zip; then
        error_msg "Failed to download mod-boot-sdcard"
    fi

    echo -e "${INFO} Extracting mod-boot-sdcard..."
    if ! unzip -q main.zip; then
        error_msg "Failed to extract mod-boot-sdcard"
        rm -f main.zip
    fi
    rm -f main.zip
    echo -e "${SUCCESS} Mod-boot-sdcard successfully downloaded and extracted."

    cd mod-boot-sdcard-main
    sudo mkdir -p openwrt/boot
    sudo mv u-boot.bin /openwrt
    sudo mv boot-mod-sdcard.tar.gz /openwrt
    sudo cp $TargetIMG /openwrt
    cd openwrt
    sudo gunzip *.img.gz
    local IMG_NAME=$(basename $TargetIMG)
    device=$(sudo losetup -fP --show $IMG_NAME)
    sudo mount ${device}p1 boot
    sudo tar xfz boot-mod-sdcard.tar.gz
    echo -e "Patching extlinux.conf"
    uenv=$(sudo cat boot/uEnv.txt | grep APPEND | awk -F "root=" '{print $2}')
    extlinux=$(sudo cat boot/extlinux/extlinux.conf | grep APPEND | awk -F "root=" '{print $2}')
    sudo sed -i "s/$extlinux/$uenv/g" boot/extlinux/extlinux.conf
    sleep 1
    echo -e "Patching boot.ini"
    if [ ${{ github.event.inputs.type_dtb }} = "b860h" ]; then
    dtb="meson-gxl-s905x-b860h.dtb"
    elif [ ${{ github.event.inputs.type_dtb }} = "hg680p" ]; then
    dtb="meson-gxl-s905x-p212.dtb"
    fi
    boot=$(sudo cat /workdir/openwrt/boot/boot.ini | grep dtb | awk -F "/" '{print $4}' | cut -d'"' -f1)
    sudo sed -i "s/$boot/$dtb/g" /workdir/openwrt/boot/boot.ini
    sudo sed -i "s/$boot/$dtb/g" /workdir/openwrt/boot/extlinux/extlinux.conf
    sudo umount ${device}p1
    sleep 1
    echo -e "Adding Amlogic Bootloader"
    sudo dd if=u-boot.bin of=${device} bs=1 count=444 conv=fsync 2>/dev/null
    sudo dd if=u-boot.bin of=${device} bs=512 skip=1 seek=1 conv=fsync 2>/dev/null
    sudo losetup -d ${device}
    echo -e "Patching Success"
    sleep 1
    echo -e "Compress file img"
    if [ ${{ github.event.inputs.type_file }} = "img.gz" ]; then
    sudo gzip ${{ github.event.inputs.name_file }}.img
    else
    sudo xz ${{ github.event.inputs.name_file }}.img
    fi
    echo -e "Compress Success"
    echo "FIRMWARE=$PWD/${{ github.event.inputs.name_file }}.${{ github.event.inputs.type_file }}" >> $GITHUB_ENV
    echo "status=success" >> $GITHUB_OUTP
}