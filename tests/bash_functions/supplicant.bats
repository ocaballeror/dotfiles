#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions
load helper

interface=wlp3s0

check_compatible() {
	for program in iwlist iwconfig wpa_supplicant ip; do
		if ! hash "$program" 2>/dev/null; then 
			errcho "$program not installed"
			return 1
		fi
	done

	if [ -z iwconfig 2>/dev/null ]; then
		errcho "No wireless interfaces"
		return 1 
	fi

	if ! ip addr | grep -q $interface; then 
		errcho "Interface $interface not available"
		return 1
	fi

	if [ ! -f /etc/wpa_supplicant/$interface.conf ]; then
		errcho "Config file does not exist"
		return 1
	fi

	sudo ip link set dev $interface up
	avail="$(sudo iwlist $interface scanning | grep -i ssid |\
		tr -d '"' | cut -d: -f2- | sort | uniq)"
	if [ -z "$avail" ]; then
		errcho "No networks available"
		return 1
	fi

	ssids="$(grep ssid "/etc/wpa_supplicant/$interface.conf" |\
		tr -d '"' | cut -d= -f2-)"
	for s in $ssids; do
		if echo "$avail" | grep -qw "$s"; then
			ssid="$s"			
		fi
	done
	if [ -z "$ssid" ]; then
		errcho "None of the available ssids is registered in the conf file"
		return 1 
	fi
}

if check_compatible; then
	incompatible=false
else
	incompatible=true
fi

setup(){
	if $incompatible; then 
		skip "Incompatible"
	fi
	tempdir="$(mktemp -d)"
	cd $tempdir
}

teardown() {
	if testconnected -n; then
		sudo pkill wpa_supplicant
	fi

	rm -rf "$temp"
}

testconnected(){
	check(){
		ip a show $interface | grep -q "state UP" &&\
		iwconfig 2>/dev/null | grep -q "ESSID:\"$ssid\""
	}

	if [ -n "$1" ] && [ "$1" = "-n" ]; then
		check
	else
		for i in $(seq 10); do
			if check; then break
			else sleep 1;
			fi
		done
	fi
}

testdisconnected(){
	[ -z "$(ps aux | grep wpa_supplicant)" ]
}

@test "Basic supplicant" {
	supplicant $ssid	
	testconnected
}


@test "Supplicant kill" {
	sudo wpa_supplicant -i$interface -c/etc/wpa_supplicant/$interface.conf -B
	testconnected

	supplicant -k
	testdisconnected
}

@test "Supplicant with a different interface" {
	run supplicant -i $interface $ssid
	testconnected
}

@test "Supplicant case autocorrection" {
	for s in $ssids; do
		if echo "$avail" | grep -qw "$s"; then
			# Check if there isn't a lowercase version in the config file
			if [ "${s,,}" != "$s" ]; then
			if ! echo "$ssids" | grep -qw "${s,,}"; then
				network="${s,,}"
				break
			fi
		else
			if ! echo "$ssids" | grep -qw "${s^^}"; then
				network="${s^^}"
				break
			fi
		fi
	fi
	done

	if [ -z "$network" ]; then
		fail "No testable network found"
	fi

	run supplicant "$network"
	[ $status = 0 ]
	[ "${lines[0]}" = "$network auto corrected to $s" ]
	testconnected
}

@test "Supplicant substring autocorrection" {
	for s in $ssids; do
		if echo "$avail" | grep -qw "$s"; then
			# Check if there isn't a lowercase version in the config file
			crippled="${s:1:-1}"
			if [ "$crippled" != "$s" ]; then
				if ! echo "$ssids" | grep -qw "$crippled"; then
					network="$crippled"
					break
				fi
			fi
		fi
	done

	if [ -z "$network" ]; then
		fail "No testable network found"
	fi

	run supplicant "$network"
	[ $status = 0 ]
	[ "${lines[0]}" = "$network auto corrected to $s" ]
	testconnected
}

@test "Supplicant on inexistent network" {
	network="$(echo $ssids | awk '{print $1}')"
	network+="somerandomjunk"

	run supplicant "$network"
	[ $status != 0 ]
	[ "$output" = "Err: SSID $network not found" ]
	testdisconnected
}

@test "Supplicant on inexistent interface" {
	oldint="$interface"
	interface="thereisnowaythisinterfaceexists"

	run supplicant -i $interface
	[ $status != 0 ]
	[ "$output" = "Err: Interface '$interface' not found" ]
	testdisconnected
	interface="$oldint"
}

@test "Supplicant on unavailable network" {
	for s in $ssids; do
		if ! echo "$avail" | grep -qwi "$s"; then
			network="$s"
			break
		fi
	done
	[ -z "$network" ] && skip "All registered networks are available"

	run supplicant "$network"
}

@test "Supplicant list" {
	[ "$(supplicant -l)" = "$(grep ssid "/etc/wpa_supplicant/$interface.conf" | tr -d '"' | cut -d= -f2-)" ]
}
