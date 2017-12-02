#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup() {
	[ -f /sys/class/backlight/intel_backlight/max_brightness ] ||\
		skip "This script only works on a laptop with intel backlight"

	max=$(cat /sys/class/backlight/intel_backlight/max_brightness)
	current=$(cat /sys/class/backlight/intel_backlight/actual_brightness)
}

teardown() {
	[ -z $current ] || brightness $current >/dev/null 2>&1
}

@test "Absolute brightness" {
	brightness 300
	[ $(cat /sys/class/backlight/intel_backlight/actual_brightness) = 300 ]	
}

@test "Absolute brightness 2" {
	brightness 100
	[ $(cat /sys/class/backlight/intel_backlight/actual_brightness) = 100 ]	
}

@test "Relative brightness +" {
	brightness 0
	brightness +40
	[ $(cat /sys/class/backlight/intel_backlight/actual_brightness) = 40 ]	
}

@test "Relative brightness -" {
	brightness -40
	[ $(cat /sys/class/backlight/intel_backlight/actual_brightness) = $(($current - 40)) ]	
}

@test "Absolute brightness %" {
	brightness 50%
	[ $(cat /sys/class/backlight/intel_backlight/actual_brightness) = $(($max/2)) ]	
}

@test "Relative brightness -%" {
	brightness -100%
	[ $(cat /sys/class/backlight/intel_backlight/actual_brightness) = 0 ]
}

@test "Relative brightness +%" {
	brightness 0
	brightness +50%
	[ $(cat /sys/class/backlight/intel_backlight/actual_brightness) = $(($max/2))   ] ||\
	[ $(cat /sys/class/backlight/intel_backlight/actual_brightness) = $(($max/2 -1)) ] ||\
	[ $(cat /sys/class/backlight/intel_backlight/actual_brightness) = $(($max/2+1)) ]
}

