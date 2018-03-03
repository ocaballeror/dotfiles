#!/bin/bash
errcho() {
	echo $* >&2
}

is_running(){
	pgrep $1 >/dev/null 2>&1
}

