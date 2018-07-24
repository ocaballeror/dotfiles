#!/bin/bash

help="Control the current music player.
Usage: $(basename $0) [play|pause|stop|next|previous|help]
"

pause() {
	case $player in
		"cmus")         cmus-remote --pause;; 		# -u
		"clementine")   clementine --play-pause;; 	# -t
		"amarok")       amarok --play-pause;; 		# -t
		"spotify") 		dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause;;
		"playerctl")    playerctl pause;;
	esac
}

stop() {
	case $player in
		"cmus")         cmus-remote --stop;; 		# -s
		"clementine")   clementine --stop;; 		# -s
		"amarok")       amarok --stop;; 			# -s
		"spotify") 		dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop;;
		"playerctl")    playerctl stop;;
	esac
}

next() {
	case $player in
		"cmus")         cmus-remote --next;; 	 	# -n
		"clementine")   clementine --next;; 	 	# -f
		"amarok")       amarok --next;; 			# -f
		"spotify") 		dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next;;
		"playerctl")    playerctl next;;
	esac
}

prev() {
	case $player in
		"cmus")         cmus-remote --prev;; 		# -r
		"clementine")   clementine --previous;;		# -r
		"amarok")       amarok --previous;; 		# -r
		"spotify") 		dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous;;
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
		"spotify")		pkill spotify;;
	esac
}

# First try to detect the player
for try in cmus clementine amarok spotify playerctl; do
	if hash "$try" 2>/dev/null && pgrep "$try" >/dev/null 2>&1; then
		player=$try
	fi
done
[ "$player" ] || { echo 'No player detected'; exit 1; }

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
