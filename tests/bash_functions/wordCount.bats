#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup() {
	temp="$(mktemp -d)"
	cd "$temp"
}

teardown(){
	cd "$HOME"
	rm -rf $temp
}

@test "Basic wordcount" {
	cat > file <<EOF
	asdf asdf asdf asdfa asdfasd.asdfasd asdf.asdf?asdfa
	asdf
	asdf
	asdfa%asdfa
EOF

	run wordCount file
	[[ "${lines[0]}" =~ .*7\ asdf ]]
	[[ "${lines[1]}" =~ .*4\ asdfa ]]
	[[ "${lines[2]}" =~ .*2\ asdfasd ]]
}

