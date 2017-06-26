#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

interface=wlp3s0
ip addr | grep -q wlp3s0 ||  { echo "Interface wlp3s0 not available"; exit 1; }
for program in iwlist iwconfig wpa_supplicant ip; do
	hash "$program" 2>/dev/null || { echo "$program not installed"; exit 1; }
done
[ -f /etc/wpa_supplicant/$interface.conf ] || { echo "Config file does not exist"; exit 1; }

[ -n iwconfig 2>/dev/null ] || { echo "No wireless interfaces"; exit 1; }

avail="$(sudo iwlist $interface scanning | grep -i ssid | tr -d '"' | cut -d: -f2- | sort | uniq)"
ssids="$(grep ssid "/etc/wpa_supplicant/$interface.conf" | tr -d '"' | cut -d= -f2-)"
for s in $ssids; do
	if echo "$avail" | grep -qw "$s"; then
		ssid="$s"			
	fi
done
if [ -z "$ssid" ]; then
	{ echo "None of the available ssids is registered in the conf file"; exit 1; }
fi

setup(){
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
	[ -z "$1" ] || [ "$1" != "-n" ] && sleep 10
	ip a show $interface | grep -q "state UP"
	iwconfig 2>/dev/null | grep -q "ESSID:\"$ssid\""
}

testdisconnected(){
	sleep 2
	[ -z "$(ps aux | grep wpa_supplicant)" ]
}

@test "Basic supplicant" {
	supplicant $ssid	
	testconnected
}


@test "Supplicant kill" {
	sudo wpa_supplicant -i$interface -c/etc/wpa_supplicant/$interface.conf -B	
	sleep 10

	supplicant -k
	testdisconnected
}

@test "Supplicant with a different interface" {
	run supplicant -i $interface $ssid
	testconnected
}

@test "Supplicant case autocorrection" {
	for s in $ssids; do
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
		# Check if there isn't a lowercase version in the config file
		crippled="${s:1:-1}"
		if [ "$crippled" != "$s" ]; then
			if ! echo "$ssids" | grep -qw "$crippled"; then
				network="$crippled"
				break
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
