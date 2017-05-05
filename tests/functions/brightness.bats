#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

max=$(cat /sys/class/backlight/intel_backlight/max_brightness)
current=$(cat /sys/class/backlight/intel_backlight/actual_brightness)

@test "Absolute brightness" {
	brightness 300
	[ $(cat /sys/class/backlight/intel_backlight/actual_brightness) = 300 ]	
}

@test "Absolute brightness 2" {
	brightness 100
	[ $(cat /sys/class/backlight/intel_backlight/actual_brightness) = 100 ]	
}

@test "Relative brightness +" {
	brightness +400
	[ $(cat /sys/class/backlight/intel_backlight/actual_brightness) = 500 ]	
}

@test "Relative brightness -" {
	brightness -40
	[ $(cat /sys/class/backlight/intel_backlight/actual_brightness) = 460 ]	
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
	brightness +50%
	[ $(cat /sys/class/backlight/intel_backlight/actual_brightness) = $(($max/2)) ] ||\
	[ $(cat /sys/class/backlight/intel_backlight/actual_brightness) = $(($max/2-1)) ] ||\
	[ $(cat /sys/class/backlight/intel_backlight/actual_brightness) = $(($max/2+1)) ]
}

[ -n $current ] && brightness $current >/dev/null 2>&1
