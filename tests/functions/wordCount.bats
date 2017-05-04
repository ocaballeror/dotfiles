#!/usr/bin/env bats

load ~/.bash_functions

temp="$(mktemp -d)"
cd $temp

@test "Basic wordcount" {
	cat > file <<EOF
	asdf asdf asdf asdfa asdfasd.asdfasd asdf.asdf?asdfa
	asdf
	asdf
	asdfa%asdfa
EOF
	
	run wordCount file
	[ $status = 0 ]
	[[ "${lines[0]}" =~ .*7\ asdf ]]
	[[ "${lines[1]}" =~ .*4\ asdfa ]]
	[[ "${lines[2]}" =~ .*2\ asdfasd ]]
}

cd "$HOME"
[ -d $temp ] && rm -rf $temp
