#!/bin/bash

help="Control the current music player.
Usage: $(basename $0) [play|pause|stop|next|previous|help]
"

pause() {
	case $player in
		"cmus")         cmus-remote --pause;; 		# -u
		"clementine")   clementine --play-pause;; 	# -t
		"amarok")       amarok --play-pause;; 		# -t
		"playerctl")    playerctl pause;;
	esac
}

stop() {
	case $player in
		"cmus")         cmus-remote --stop;; 		# -s
		"clementine")   clementine --stop;; 		# -s
		"amarok")       amarok --stop;; 			# -s
		"playerctl")    playerctl stop;;
	esac
}

next() {
	case $player in
		"cmus")         cmus-remote --next;; 	 	# -n
		"clementine")   clementine --next;; 	 	# -f
		"amarok")       amarok --next;; 			# -f
		"playerctl")    playerctl next;;
	esac
}

prev() {
	case $player in
		"cmus")         cmus-remote --prev;; 		# -r
		"clementine")   clementine --previous;;		# -r
		"amarok")       amarok --previous;; 		# -r
		"playerctl")    playerctl previous;;
	esac
}

# Accepts a relative offset in seconds (e.g. +5)
seek() {
	case $player in
		"cmus")         cmus-remote --seek $1;;
		"clementine")   clementine --seek-by $1;;
	esac
}

quit() {
	case $player in
		"cmus") 		cmus-remote -C quit;;
		"clementine") 	pkill clementine;;
		"amarok") 		pkill amarok;;
	esac
}

# First try to detect the player
if hash cmus 2>/dev/null && cmus-remote -Q >/dev/null 2>&1; then
	player=cmus
elif hash clementine 2>/dev/null && pgrep clementine >/dev/null 2>&1; then
	player=clementine
elif hash amarok 2>/dev/null && pgrep amarok >/dev/null 2>&1; then
	player=amarok
elif hash playerctl 2>/dev/null; then
	player=playerctl
fi


case $1 in
	play|pause|toggle)
		pause;;
	stop)
		stop;;
	next)
		next;;
	previous|prev)
		prev;;
	seek)
		seek $2;;
	quit)
		quit;;
	help|-h|--help)
		echo $help;;
esac
