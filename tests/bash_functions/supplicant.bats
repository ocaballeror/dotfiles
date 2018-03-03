#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/../../bash/.bash_functions"
load helper
load net_helper

interface=wlp3s0
ssid="placeholder" #overwritten by check_compatible

setup(){
	check_compatible
}

@test "Basic supplicant" {
	# test_connected -rn && disconnect
	supplicant "$ssid"
	test_connected
	# disconnect
}

@test "Supplicant kill" {
	test_connected -n || sudo wpa_supplicant -i$interface -c/etc/wpa_supplicant/$interface.conf -B
	test_connected

	supplicant -k
	test_connected -r
}

@test "Supplicant on downed interface" {
	disconnect
	test_connected -r
	sudo ip link set dev "$interface" down
	supplicant "$ssid"
	test_connected
}


@test "Supplicant with a different interface" {
	disconnect
	sudo ip link set dev $interface down
	sudo ip link set dev $interface name newname
	sudo ip link set dev newname up
	oldinterface=$interface
	interface=newname
	sudo cp /etc/wpa_supplicant/$oldinterface.conf /etc/wpa_supplicant/$interface.conf

	supplicant -i newname $ssid
	run test_connected

	sudo ip link set dev $interface down
	sudo ip link set dev $interface name $oldinterface
	sudo ip link set dev $oldinterface up
	sudo rm /etc/wpa_supplicant/$interface.conf
	interface=$oldinterface
	
	if [ $status != 0 ]; then
		fail "$output"
	fi
}

@test "Supplicant case autocorrection" {
	disconnect
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
	test_connected
}

@test "Supplicant substring autocorrection" {
	disconnect
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
	test_connected
}

@test "Supplicant ambiguous substring" {
	skip "Not yet implemented"
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
	[ status != 0 ]
	[ "$output" = "Err: $network is not available right now" ]
}

@test "Supplicant on inexistent network" {
	disconnect

	network="$(echo $ssids | awk '{print $1}')"
	network+="somerandomjunk"

	run supplicant "$network"
	[ $status != 0 ]
	[ "$output" = "Err: SSID $network not found" ]
	test_connected -r
}

@test "Supplicant on inexistent interface" {
	disconnect

	oldint="$interface"
	interface="theresnowaythisinterfaceexists"

	run supplicant -i $interface
	[ $status != 0 ]
	[ "$output" = "Err: Interface '$interface' not found" ]
	test_connected -r
	interface="$oldint"
}

@test "Supplicant list" {
	[ "$(supplicant -l)" = "$(grep ssid "/etc/wpa_supplicant/$interface.conf" | tr -d '"' | cut -d= -f2-)" ]
}
