#!/bin/bash
#
# Input parser for i3 bar
# 14 ago 2015 - Electro7

# config
. $(dirname $0)/i3_lemonbar_config

# min init
irc_n_high=0
title="%{F${color_head} B${color_sec_b2}}${sep_right}%{F${color_head} B${color_sec_b2}%{T2} ${icon_prog} %{F${color_sec_b2} B-}${sep_right}%{F- B- T1}"

# parser
while read -r line ; do
	case $line in
		DAT*)
			# Date
			if $date_enable; then
				line=( ${line:3} )
				if [ ${res_w} -gt 1366 ]; then
					date="${line[0]} ${line[1]} ${line[2]}"
				else
					date="${line[1]} ${line[2]}"
				fi
				date="%{F${color_sec_b1}}${sep_left}%{F${color_icon} B${color_sec_b1}} %{T2}${icon_clock}%{F- T1} ${date}"
			fi;;
		TIM*) 
			# Time
			if $time_enable; then
				time="%{F${color_head}}${sep_left}%{F${color_back} B${color_head}} ${line:3} %{F- B-}"
			fi;;

		CPU*)
			# Cpu
			if $cpu_enable; then
				if [ ${line:3} -gt ${cpu_alert} ]; then
					cpu_cback=${color_cpu}; cpu_cicon=${color_back}; cpu_cfore=${color_back};
				else
					cpu_cback=${color_sys_b1}; cpu_cicon=${color_icon}; cpu_cfore=${color_fore};
				fi
				cpu="%{F${cpu_cback}}${sep_left}%{F${cpu_cicon} B${cpu_cback}} %{T2}${icon_cpu}%{F${cpu_cfore} T1} ${line:3}%"
			fi;;
		MEM*)
			# Mem
			if $mem_enable; then
				mem="%{F${cpu_cicon}}${sep_l_left} %{T2}${icon_mem}%{F${cpu_cfore} T1} ${line:3}"
			fi;;

		BAT*)
			# Battery
			if $battery_enable; then
				line=( ${line:3} )
				if [ "${line[0]}" != "down" ] && [ "${sys_arr[7]}" != "down" ]; then
					if [ "${line[0]}" = "C" ]; then
						icon_bat="$icon_charging"
					else
						icon_bat="$icon_battery"
					fi
					bat="%{F${cpu_cicon}}${sep_l_left} %{T2}${icon_bat}%{F${cpu_cfore} T1} ${line[1]}"
				fi
			fi;;
		FSR*)
			# Disk /
			if $disk_root_enable; then
				diskr="%{F${color_store_b1}}${sep_left}%{F${color_icon} B${color_store_b1}} %{T2}${icon_hd}%{F${color_black}}%{F- T1} ${line:3}"
			fi;;
		FSH*) 
			# Disk /home
			if $disk_home_enable; then
				diskh="%{F${color_icon}}${sep_l_left} %{T2}${icon_home}%{F- T1} ${line:3}"
			fi;;

		WLN*)
			# Wlan
			if $net_enable; then
				line=( ${line:3} )
				if [ "${line[0]}" != "down" ]; then
					wlan_ip=${line[0]}; wlan_ssid=${line[1]};
					wlanip="%{F${wlan_cback}}${sep_left}%{F${wlan_cicon} B${wlan_cback}} %{T2}${icon_wifi}%{F${wlan_cfore} T1} ${wlan_ip}"
					wlanssid="%{F${wlan_cicon}}${sep_l_left} %{F${wlan_cfore} T1} ${wlan_ssid}"
				else
					wlan_ip=""; wlan_ssid="";
					wlanip=""; wlanssid="";
				fi
				wlan_cback=${color_net_b1}; wlan_cicon=${color_icon}; wlan_cfore=${color_fore};
			fi;;
		ETH*)
			# Eth
			if $net_enable; then
				if [ "${line:3}" != "down" ]; then
					eth_ip="${line:3}"
					eth_cback=${color_net_b1}; eth_cicon=${color_icon}; eth_cfore=${color_fore};
					ethip="%{F${eth_cback}}${sep_left}%{F${eth_cicon} B${eth_cback}} %{T2}${icon_wired}%{F${eth_cfore} T1} ${eth_ip}"
				else
					eth_ip=""; ethip="";
				fi
			fi
			;;
		VOL*)
			# Volume
			vol="%{F${color_sec_b2}}${sep_left}%{F${color_icon} B${color_sec_b2}} %{T2}${icon_vol}%{F- T1} ${line:3}%"
			;;
		GMA*)
			# Gmail
			if $gmail_enable; then
				gmail="${line:3}"
				if [ "${gmail}" != "0" ]; then
					mail_cback=${color_mail}; mail_cicon=${color_back}; mail_cfore=${color_back}
				else
					mail_cback=${color_sec_b1}; mail_cicon=${color_icon}; mail_cfore=${color_fore}
				fi
				gmail="%{F${mail_cback}}${sep_left}%{F${mail_cicon} B${mail_cback}} %{T2}${icon_mail}%{F${mail_cfore} T1} ${gmail}"
			fi
			;;
		IRC*)
			# IRC highlight (script irc_warn)
			if $irc_enable; then
				if [ "${line:3}" != "0" ]; then
					((irc_n_high++)); irc_high="${line:3}";
					irc_cback=${color_chat}; irc_cicon=${color_back}; irc_cfore=${color_back}
				else
					irc_n_high=0; [ -z "${irc_high}" ] && irc_high="none";
					irc_cback=${color_sec_b2}; irc_cicon=${color_icon}; irc_cfore=${color_fore}
				fi
				irc="%{F${irc_cback}}${sep_left}%{F${irc_cicon} B${irc_cback}} %{T2}${icon_chat}%{F${irc_cfore} T1} ${irc_n_high} %{F${irc_cicon}}${sep_l_left} %{T2}${icon_contact}%{F${irc_cfore} T1} ${irc_high}"
			fi
			;;
		MPD*)
			# MPD
			if $mpd_enable; then
				mpd_arr=(${line:3})
				if [ -n "${line:3}" ] && [ "${mpd_arr[0]}" != "error:" ]; then
					song="${line:3}";
					music="%{F${color_music_bg}}${sep_left}%{B${color_music_bg}}%{F${color_music_bg}}${sep_left}%{F${color_icon} B${color_music_bg}} %{T2}${icon_music}%{F${color_music_fg} T1}  ${song}"
				fi
			fi
			;;
		CMU*)
			# CMUs
			if $cmus_enable; then
				mpd_arr=(${line:3})
				if [ -n "${line:3}" ] && [ "${mpd_arr[0]}" != "down" ]; then
					song="${line:3}"
					#         #arrow head                   #arrow bg          #arrow_head                     #icon          #main bg                                #main fg 
					music="%{F${color_music_bg}}${sep_left}%{B${color_music_bg}}%{F${color_music_bg}}${sep_left}%{F${color_icon} B${color_music_bg}} %{T2}${icon_music}%{F${color_music_fg} T1}  ${song}"
				else
					song=""; music="";
				fi
			fi
			;;
		WSP*)
			# I3 Workspaces
			wsp="%{F${color_back} B${color_head}} %{T2}${icon_wsp}%{T1}"
			set -- ${line:3}
			while [ $# -gt 0 ] ; do
				case $1 in
					FOC*)
						wsp="${wsp}%{F${color_head} B${color_wsp}}${sep_right}%{F${color_back} B${color_wsp} T1} ${1#???} %{F${color_wsp} B${color_head}}${sep_right}"
						;;
					INA*|URG*|ACT*)
						wsp="${wsp}%{F${color_disable} T1} ${1#???} "
						;;
				esac
				shift
			done
			;;
		WIN*)
			# window title
			title=$(xprop -id ${line:3} | awk '/_NET_WM_NAME/{$1=$2="";print}' | cut -d'"' -f2)
			#title="%{F${color_head} B${color_sec_b2}}${sep_right}%{F${color_head} B${color_sec_b2}%{T2} ${icon_prog} %{F${color_sec_b2} B-}${sep_right}%{F- B- T1} ${title}"
			title="%{F${color_head} B${color_sec_b2}}${sep_right}%{F${color_head} B${color_sec_b2} T2} ${icon_prog} %{F${color_sec_b2} B-}${sep_right}%{F- B- T1} ${title}"
			;;
	esac

	# And finally, output
	bar="%{l}${wsp}${title} %{r}"
	for var in music vol irc gmail wlanip wlanssid ethip diskr diskh cpu mem bat date time; do
		# If variable is set, add it
		if [ -n "$(eval echo \$$var)" ]; then
			if [ $var != "time" ]; then #Clunky as hell, but avoids printing an extra '<' at the end
				bar+="$(eval echo \$$var)${stab}"
			else
				bar+="$(eval echo \$$var)"
			fi
		fi
done

ret=""
mcount="$(xrandr --listactivemonitors | head -1 | awk '{print $2}')"
for i in $(seq 0 $((mcount -1))); do
		ret+="%{S$i}$bar"
done

echo "$ret"
done
