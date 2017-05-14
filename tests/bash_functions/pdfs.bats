#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup() {
	temp="$(mktemp -d)"
	cd $temp

	file1=file1.pdf
	file2=file2.pdf
	echo a > "$file1"
	echo b > "$file2"
}

teardown() {
	cd "$HOME"
	rm -rf "$temp"
}

@test "Pdfs" {
	if ! hash firefox 2>/dev/null; then
		skip "Default viewer firefox is not installed"
	fi
	pdfs
	run bash -c "ps aux | grep \"firefox.*$file1 $file2\" | grep -v grep"	
	[ $status = 0 ]
	kill "$(echo "$output" | head -1 | awk '{print $2}')"
}

@test "Pdfs with a different viewer" {
	for viewer in chromium xpdf mupdf evince okular nope; do
		if hash $viewer 2>/dev/null; then
			break;
		fi
	done
	if [ "$viewer" = nope ]; then
		skip "No known pdf viewer is installed"
	fi
	
	pdfs -v $viewer
	run bash -c "ps aux | grep \"$viewer $file1 $file2\" | grep -v grep"	
	[ $status = 0 ]
	kill "$(echo "$output" | head -1 | awk '{print $2}')"
}

@test "Pdfs with nonexistent viewer" {
	run pdfs -v "thispdfviewerdoesnotexist"
	[ $status != 0 ]
}

@test "Pdfs on a different directory" {
	cd "$HOME"
	pdfs "$temp"
	run bash -c "ps aux | grep \"firefox $file1 $file2\" | grep -v grep"	
	[ $status = 0 ]
	kill "$(echo "$output" | head -1 | awk '{print $2}')"
}
