if ! hash synclient 2>/dev/null; then
	echo "Err: synclient not found. Install xorg's xf86-input-synaptics and try again" >&2
	return 1
fi
if synclient -l | grep "TouchpadOff .*=.*0" >/dev/null; then
	synclient TouchpadOff=1
else
	synclient TouchpadOff=0
fi

