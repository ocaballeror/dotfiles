#!/bin/bash

help="Control the current music player.
Usage: $(basename $0) [play|pause|stop|next|previous|help]
"

# First try to detect the player
if hash cmus 2>/dev/null && cmus-remote -Q >/dev/null 2>&1; then
	pause="cmus-remote --pause" # -u
	next="cmus-remote --next" 	# -n
	prev="cmus-remote --prev" 	# -r
	stop="cmus-remote --stop" 	# -s
elif hash clementine 2>/dev/null && pgrep clementine >/dev/null 2>&1; then
	pause="clementine --play-pause" 	# -t
	next="clementine --next"        	# -f
	prev="clementine --previous"    	# -r
	stop="clemetine --stop"         	# -s
elif hash playerctl 2>/dev/null; then
	pause="playerctl pause"
	next="playerctl next"
	prev="playerctl previous"
	stop="playerctl stop"
fi



case $1 in
	play|pause|toggle)
		( $pause );;
	stop)
		( $stop );;
	next)
		( $next );;
	previous|prev)
		( $prev );;
	help|-h|--help)
		echo $help;;
esac
