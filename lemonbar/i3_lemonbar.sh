#! /bin/bash
#
# I3 bar with https://github.com/LemonBoy/bar

. $(dirname $0)/i3_lemonbar_config

if [ $(pgrep -cx $(basename $0)) -gt 1 ] ; then
	echo "The status bar is already running." >&2
	exit 1
fi

trap 'trap - TERM; kill 0' INT TERM QUIT EXIT

[ -e "${panel_fifo}" ] && rm "${panel_fifo}"
mkfifo "${panel_fifo}"

### EVENTS METERS

# Window title, "WIN"
xprop -spy -root _NET_ACTIVE_WINDOW | sed -un 's/.*\(0x.*\)/WIN\1/p' > "${panel_fifo}" &

# i3 Workspaces, "WSP"
# TODO : Restarting I3 breaks the IPC socket con. :(
$(dirname $0)/i3_workspaces.py > "${panel_fifo}" &

# Conky, "SYS"
v1="$(conky --version | head -1 | cut -d ' ' -f1,2 | tr -dc '[:digit:]\.\n' | awk -F. '{ printf("%03d%03d%03d\n", $1,$2,$3); }')"
v2="$(echo "1.9" | awk -F. '{ printf("%03d%03d%03d\n", $1,$2,$3); }')"

if [ "$v1" -gt "$v2" ]; then
	conky -c $(dirname $0)/i3_lemonbar_conky > "${panel_fifo}" &
else
	conky -c $(dirname $0)/i3_lemonbar_conky_1.9 > "${panel_fifo}" &
fi

# IRC, "IRC"
# only for init
if $irc_enable && test -f ~/bin/irc_warn; then
	~/bin/irc_warn &
fi

### UPDATE INTERVAL METERS
cnt_mail=${upd_mail}
cnt_mpd=${upd_mpd}
cnt_cmus=${upd_cmus}

while true; do
	# GMAIL, "GMA"
	if $gmail_enable; then
		if [ $((cnt_mail++)) -ge ${upd_mail} ]; then
			printf "%s%s\n" "GMA" "$(~/bin/gmail.sh)" > "${panel_fifo}"
			cnt_mail=0
		fi
	fi

	# MPD
	if $mpd_enable; then
		if [ $((cnt_mpd++)) -ge ${upd_mpd} ]; then
			#printf "%s%s\n" "MPD" "$(ncmpcpp --now-playing '{%a - %t}|{%f}' | head -c 60)" > "${panel_fifo}"
			printf "%s%s\n" "MPD" "$(mpc current -f '[[%artist% - ]%title%]|[%file%]' 2>&1 | head -c 70)" > "${panel_fifo}"
			cnt_mpd=0
		fi
	fi

	#CMUS
	if $cmus_enable; then
		if [ $((cnt_cmus++)) -ge ${upd_cmus} ]; then
			if ! cmus-remote >/dev/null 2>&1; then
				echo "CMUdown" > "${panel_fifo}"
			else
				artist="$(cmus-remote -Q | grep artist | head -1 | cut -d ' ' -f3-)"
				title="$(cmus-remote -Q | grep title | head -1 | cut -d ' ' -f3- )"
				elapsed="$(cmus-remote -Q | grep position | awk '{print $2}')"
				total="$(cmus-remote -Q | grep duration | awk '{print $2}')"
				time="$(printf '(%02d:%02d / %02d:%02d)\n'\
					$((elapsed / 60)) $((elapsed % 60))\
					$((total / 60)) $((total % 60)))"

				printf "%s%s - %s %s\n" "CMU" "$artist" "$title" "$time" > "${panel_fifo}"
			fi
			cnt_cmus=0
		fi
	fi

	# Finally, wait 1 second
	sleep 1s;

done &

#### LOOP FIFO
cat "${panel_fifo}" | $(dirname $0)/i3_lemonbar_parser.sh \
	| lemonbar -f "${font}" -f "${iconfont}" -g "${geometry}" -B "${color_back}" -F "${color_fore}" &

wait

