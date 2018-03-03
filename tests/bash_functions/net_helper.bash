#!/bin/bash

timeout=15

check_compatible() {
	for program in iwlist iwconfig wpa_supplicant ip; do
		if ! hash "$program" 2>/dev/null; then 
			skip "$program not installed"
		fi
	done

	if [ -z "$(iwconfig 2>/dev/null)" ]; then
		skip "No wireless interfaces"
	fi

	if ! ip addr | grep -q "$interface"; then 
		skip "Interface $interface not available"
	fi

	if [ ! -f "/etc/wpa_supplicant/$interface.conf" ]; then
		skip "Config file does not exist"
	fi

	sudo ip link set dev "$interface" up
	avail="$(sudo iwlist "$interface" scanning | grep -i ssid |\
		tr -d '"' | cut -d: -f2- | sort | uniq)"
	if [ -z "$avail" ]; then
		skip "No networks available"
	fi

	ssids="$(grep ssid "/etc/wpa_supplicant/$interface.conf" |\
		tr -d '"' | cut -d= -f2-)"
	for s in $ssids; do
		if echo "$avail" | grep -qw "$s"; then
			ssid="$s"			
		fi
	done
	if [ -z "$ssid" ]; then
		skip "None of the available ssids is registered in the conf file"
	fi
}

test_connected(){
	_connected(){
		ip a show "$interface" | grep -q "state UP"
	}
	_disconnected(){
		! is_running wpa_supplicant && ! _connected
	}
	_check(){
		if $reverse; then _disconnected
		else _connected
		fi
	}

	local reverse onetime
	reverse=false
	onetime=false
	OPTIND=1
	while getopts ':rn' opt; do
		case $opt in
			r) reverse=true;;
			n) onetime=true;;
			*) true;;
		esac
	done

	if $onetime; then
		_check
		return
	else
		for i in $(seq $timeout); do
			if _check; then return 0
			else sleep 1;
			fi
		done
		return 1
	fi
}

disconnect() {
	_main_disconnect(){
		if is_running $1; then
			sudo pkill $1
		else return 0
		fi

		for i in $(seq $timeout); do
			is_running $1 || break
			sleep 1
		done

		if is_running $1; then
			sudo pkill -9 $1
		else return 0
		fi

		for i in $(seq $timeout); do
			is_running $1 || break
			sleep 1
		done
		is_running $1 && fail "Can't disconnect"
	}
	test_connected -n || return 0
	# sudo ip link set dev "$interface" down
	_main_disconnect wpa_supplicant
	[ -e /run/wpa_supplicant ] && rm /run/wpa_supplicant || true
	_main_disconnect netctl
	_main_disconnect nm
}

