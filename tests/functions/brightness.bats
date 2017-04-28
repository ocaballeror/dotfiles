#!/usr/bin/env bats

load $HOME/.bash_functions

wsetup(){
	max=$(cat /sys/class/backlight/intel_backlight/max_brightness)
	current=$(cat /sys/class/backlight/intel_backlight/actual_brightness)
}
wteardown() {
	brightness $current >/dev/null 2>&1
}

@test "Absolute brightness" {
	wsetup
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

@test "Relative brightness +%" {
	brightness +50%
	[ $(cat /sys/class/backlight/intel_backlight/actual_brightness) = $max ] ||\
	[ $(cat /sys/class/backlight/intel_backlight/actual_brightness) = $(($max-1)) ]	
}

@test "Relative brightness -%" {
	brightness -100%
	[ $(cat /sys/class/backlight/intel_backlight/actual_brightness) = 0 ]
	wteardown
}

