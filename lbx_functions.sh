#!/bin/sh

PIRATEBOX_FOLDER=/opt/piratebox
PIRATEBOX_CONFIG="${PIRATEBOX_FOLDER}"/conf/piratebox.conf

FTP_CONFIG_SCRIPT="${PIRATEBOX_FOLDER}""/bin/ftp_enable.sh"
FTP_CONFIG_AVAILABLE="-e $FTP_CONFIG_SCRIPT"


### Configuration stuff
SWAP_PARTITION="/dev/mmcblk0p3"
EXT_PARTITION="/dev/mmcblk0p4"
EXT_MOUNTPOINT="/mnt/sdcard"

do_enable_wifi_hotspot(){
	sed 's|DO_BRIDGE="no"|DO_BRIDGE="yes"|' 	-i  $PIRATEBOX_CONFIG
	sed 's|USE_APN="no"|USE_APN="yes"|'         	-i  $PIRATEBOX_CONFIG
	sed 's|PROBE_INTERFACE="no"|PROBE_INTERFACE="yes"|' -i  $PIRATEBOX_CONFIG
}

do_disable_wifi_hotspot(){
        sed 's|DO_BRIDGE="yes"|DO_BRIDGE="no"|'         -i  $PIRATEBOX_CONFIG
        sed 's|USE_APN="yes"|USE_APN="no"|'             -i  $PIRATEBOX_CONFIG
	sed 's|PROBE_INTERFACE="yes"|PROBE_INTERFACE="no"|' -i  $PIRATEBOX_CONFIG
}

do_timesave_enable() {
	${PIRATEBOX_FOLDER}/bin/timesave.sh  install
	systemctl enable cronie.service

	echo "
[Unit]
Description=Restore fake RTC-time

[Service]
ExecStart=/bin/bash ${PIRATEBOX_FOLDER}/bin/timesave.sh recover

[Install]
WantedBy=multi-user.target 
" >  /etc/systemd/system/timesave.service
	systemctl enable timesave.service
	
} 

do_netctl_lan_to_piratebox(){
	if ! netctl is-enabled lan_piratebox_bridge  ; then
		netctl disable  lan_dhcp
		netctl enable lan_piratebox_bridge 
	fi
}

do_netctl_lan_as_single_dhcp(){
	if ! netctl is-enabled lan_dhcp  ; then
		netctl disable lan_piratebox_bridge
		netctl enable lan_dhcp
	fi
}

do_launch_ftp_setup(){
	if $FTP_CONFIG_AVAILABLE ; then
		. $FTP_CONFIG_SCRIPT
	else 
		return 128
	fi
}

do_swapon_step1(){

fdisk /dev/mmcblk0 <<EOF
n
p
3

+256M
w

EOF

echo "
[Unit]
Description=Make SWAP Filesystem once

[Service]
ExecStart=/bin/bash /bin/cli_lbx.sh do_swapon_step2

[Install]
WantedBy=multi-user.target 
" >  /etc/systemd/system/make_swap.service
systemctl enable make_swap.service

whiptail --msgbox "SWAP Partition created. it will be installed during next boot"

}

do_swapon_step2(){
	mkswap ${SWAP_PARTITION}
	echo "${SWAP_PARTITION}    none swap defaults 0 0" >> /etc/fstab 
	systemctl disable make_swap.service
	swapon ${SWAP_PARTITION}
}

do_ext_step1(){

fdisk /dev/mmcblk0 <<EOF
n
p
4


w

EOF

echo "
[Unit]
Description=Create Storage Filesystem on SD-Card

[Service]
ExecStart=/bin/bash /bin/cli_lbx.sh do_ext_step2

[Install]
WantedBy=multi-user.target 
" >  /etc/systemd/system/make_ext.service
systemctl enable make_ext.service

whiptail --msgbox "EXT Partition created. it will be installed during next boot"

}

do_ext_step2(){
	mkdir -p  ${EXT_MOUNTPOINT}
	mkfs.ext4 ${EXT_PARTITION}
        echo "${EXT_PARTITION}     ${EXT_MOUNTPOINT}   auto defaults 0 0" >> /etc/fstab
        systemctl disable make_ext.service
        mount ${EXT_MOUNTPOINT} 
}


