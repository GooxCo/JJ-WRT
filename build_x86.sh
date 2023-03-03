#!/bin/bash

OUTPUT="$(pwd)/images"
BUILD_VERSION="22.03.3"
BUILDER="https://downloads.openwrt.org/releases/${BUILD_VERSION}/targets/x86/64/openwrt-imagebuilder-${BUILD_VERSION}-x86-64.Linux-x86_64.tar.xz"
KERNEL_PARTSIZE=200 #Kernel-Partitionsize in MB
ROOTFS_PARTSIZE=3096 #Rootfs-Partitionsize in MB
BASEDIR=$(realpath "$0" | xargs dirname)

# download image builder
if [ ! -f "${BUILDER##*/}" ]; then
	wget "$BUILDER"
	tar xJvf "${BUILDER##*/}"
fi

[ -d "${OUTPUT}" ] || mkdir "${OUTPUT}"

cd openwrt-*/

# clean previous images
make clean

# Packages are added if no prefix is given, '-packaganame' does not integrate a package
sed -i "s/CONFIG_TARGET_KERNEL_PARTSIZE=.*/CONFIG_TARGET_KERNEL_PARTSIZE=$KERNEL_PARTSIZE/g" .config
sed -i "s/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=$ROOTFS_PARTSIZE/g" .config
sed -i "s|CONFIG_DEFAULT_dnsmasq=.*|# CONFIG_DEFAULT_dnsmasq is not set|g" .config

make image PROFILE="generic" \
           PACKAGES="luci-app-firewall liblucihttp liblucihttp-lua libnetwork losetup lsattr lsblk lscpu mkf2fs \
                     wpa-cli wpa-supplicant hostapd uuidgen wget-ssl whereis which wireless-tools \
                     base-files block-mount fdisk mount-utils \
                     bash luci-base luci-ssl luci-mod-admin-full luci-theme-bootstrap luci-theme-material \
                     e2fsprogs f2fs-tools resize2fs dosfstools dumpe2fs e2freefrag exfat-mkfs \
                     htop luci-compat luci-lib-ipkg dnsmasq-full -dnsmasq luci-app-ttyd \
                     irqbalance acpid attr bc blkid blockd bsdtar  \
                     curl wget-ssl file htop usbutils diffutils pv px5g-wolfssl rename resize2fs runc subversion-client subversion-libs tar \
                     nano git-http jq gawk getopt openssl-util parted perl-http-date perlbase-file perlbase-getopt \
                     btrfs-progs busybox bzip2 cgi-io chattr comgt comgt-ncm containerd coremark \
                     urngd usign coreutils coreutils-base64 coreutils-nohup coreutils-stat coreutils-truncate  \
                     dropbear hostapd-common hostapd-utils iconv iw iwinfo jshn  \
                     zlib wireless-regdb f2fsck libjson-script perlbase-time perlbase-unicode perlbase-utf8 pigz ppp \
                     tini ttyd tune2fs uclient-fetch uhttpd uhttpd-mod-ubus unzip uqmi usb-modeswitch \
                     wwan xfs-fsck xfs-mkfs xz xz-utils ziptool zoneinfo-asia zoneinfo-core zstd \
                     \
                     luci luci-base luci-compat luci-lib-base luci-lib-ip luci-lib-ipkg luci-lib-jsonc luci-lib-nixio \
                     luci-mod-network luci-mod-system luci-proto-ipv6 luci-proto-ppp \
                     \
                     php8 php8-cgi php8-mod-ctype php8-mod-fileinfo php8-mod-gettext php8-mod-gmp php8-mod-iconv php8-mod-mbstring php8-mod-pcntl php8-mod-session php8-mod-zip php8-mod-curl php8-mod-dom \
                     php8-mod-filter php8-mod-opcache php8-mod-pdo\
                     \
                     netdata luci-app-vnstat2 luci-app-opkg ca-certificates \
                     \
                     iw-full iwinfo iwl3945-firmware iwl4965-firmware iwlwifi-firmware-iwl100 \
                     iwlwifi-firmware-iwl1000 iwlwifi-firmware-iwl105 iwlwifi-firmware-iwl135 \
                     iwlwifi-firmware-iwl2000 iwlwifi-firmware-iwl2030 iwlwifi-firmware-iwl3160 iwlwifi-firmware-iwl3168 iwlwifi-firmware-iwl5000 iwlwifi-firmware-iwl5150 \
                     iwlwifi-firmware-iwl6000g2 iwlwifi-firmware-iwl6000g2a iwlwifi-firmware-iwl6000g2b iwlwifi-firmware-iwl6050 \
                     iwlwifi-firmware-iwl7260 iwlwifi-firmware-iwl7265 iwlwifi-firmware-iwl7265d iwlwifi-firmware-iwl8260c iwlwifi-firmware-iwl8265 iwlwifi-firmware-iwl9000 iwlwifi-firmware-iwl9260 \
                     \
                     kmod-iwl-legacy kmod-iwl3945 kmod-iwl4965 \
                     kmod-iwlwifi kmod-kvm-intel kmod-kvm-x86 \
                     kmod-kvm-amd kmod-tun kmod-usb-net-rtl8150 kmod-e100 \
                     \
                     kmod-ath kmod-ath6kl kmod-ath6kl-usb kmod-ath9k kmod-ath9k-common kmod-ath9k-htc \
                     \
                     pciutils p54-pci-firmware p54-usb-firmware pciids \
                     \
                     rs9113-firmware rt2800-pci-firmware rt61-pci-firmware rt73-usb-firmware \
                     rtl8188eu-firmware rtl8192ce-firmware rtl8192cu-firmware rtl8192de-firmware \
                     rtl8192eu-firmware rtl8192se-firmware rtl8192su-firmware rtl8723au-firmware \
                     rtl8723bu-firmware rtl8821ae-firmware rtl8822be-firmware rtl8822ce-firmware \
                     \
                     kmod-hermes kmod-hermes-pci kmod-hfcmulti kmod-hfcpci kmod-hid kmod-hid-generic \
                     \
                     kmod-usb-wdm kmod-brcmsmac kmod-usb-net-ipheth kmod-usb-net-asix-ax88179 \
                     kmod-crypto-acompress kmod-crypto-crc32c kmod-crypto-hash kmod-fs-btrfs \
                     kmod-usb-net-rndis kmod-usb-net-cdc-ncm kmod-usb-net-cdc-eem kmod-usb-net-cdc-subset \
                     kmod-usb-net-cdc-ether kmod-rtl8xxxu kmod-rtl8187 kmod-nft-tproxy \
                     kmod-rtl8xxxu rtl8188eu-firmware kmod-rtl8192ce kmod-rtl8192cu kmod-rtl8192de \
                     kmod-fs-squashfs squashfs-tools-unsquashfs squashfs-tools-mksquashfs \
                     kmod-usb-core kmod-usb3 kmod-nls-base kmod-usb-core kmod-usb-net kmod-usb2 kmod-fs-ext4 kmod-brcmfmac kmod-brcmutil \
                     kmod-cfg80211 kmod-lib80211 kmod-mac80211 kmod-usb-storage kmod-usb-ohci kmod-usb-uhci \
                     kmod-usb-net-huawei-cdc-ncm kmod-usb-serial kmod-usb-serial-option kmod-usb-serial-wwan usbutils \
                     kmod-usb-net-asix kmod-usb-net-asix-ax88179 kmod-usb-net-dm9601-ether kmod-usb-net-rtl8152 \
                     kmod-fs-f2fs kmod-fs-vfat kmod-rt2800-usb rt2800-usb-firmware kmod-rtl8192cu kmod-fs-exfat" \
            FILES="${BASEDIR}/files/" \
            BIN_DIR="${OUTPUT}"
