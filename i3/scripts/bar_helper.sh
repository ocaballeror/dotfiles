thisdir="$(dirname $(readlink -f $0))"
config="$HOME/.config"
[ -n "$XDG_CONFIG_HOME" ] && config="$XDG_CONFIG_HOME"

echo "$(date) --- $*" >> ~/bar
if [ "$1" = "init" ]; then
	if [ -f "$config/lemonbar/i3_lemonbar.sh" ] && [ -z $LEMONBAR_DISABLE ]; then
		echo "	$(date) --- Init lemonbar " >> ~/bar
		i3-msg bar mode dock lemonbar
		i3-msg bar mode invisible i3status
		echo "lemonbar" > "$thisdir/active"
		i3-msg restart
	else
		echo "	$(date) --- Init i3status " >> ~/bar
		i3-msg bar mode invisible lemonbar
		i3-msg bar mode dock i3status
		kill $(ps aux | grep "i3bar --bar_id=lemonbar" | grep -v grep | awk '{print $2}')
		echo "i3status" > "$thisdir/active"
	fi
elif [ "$1" = "restart" ]; then
	if [ -f "$config/lemonbar/i3_lemonbar.sh" ] && [ -z $LEMONBAR_DISABLE ]; then
		echo "	$(date) --- Init lemonbar " >> ~/bar
		echo "lemonbar" > "$thisdir/active"
		if ! pgrep lemonbar >/dev/null; then
			i3-msg bar mode dock lemonbar
			i3-msg bar mode invisible i3status
		fi
	else
		echo "	$(date) --- Init i3status " >> ~/bar
		i3-msg bar mode invisible lemonbar
		i3-msg bar mode dock i3status
		kill $(ps aux | grep "i3bar --bar_id=lemonbar" | grep -v grep | awk '{print $2}')
		echo "i3status" > "$thisdir/active"
	fi
elif [ "$1" = "switch" ]; then
	if [ $(cat "$thisdir/active") = "i3status" ]; then
		if [ -z "$LEMONBAR_DISABLE" ]; then
			echo "	$(date) --- Switch to lemonbar " >> ~/bar
			echo "lemonbar" > "$thisdir/active"
			i3-msg bar mode dock lemonbar
			i3-msg bar mode invisible i3status
			
			i3bar --bar_id=lemonbar &
			i3-msg restart
		else
			i3-msg bar mode dock i3status
			i3-msg bar mode invisible lemonbar	
			pkill lemonbar
		fi
	elif [ $(cat "$thisdir/active") = "lemonbar" ]; then
		echo "	$(date) --- Switch to i3status " >> ~/bar
		echo "i3status" > "$thisdir/active"
		i3-msg bar mode dock i3status
		i3-msg bar mode invisible lemonbar	
		pkill lemonbar
	fi
fi
