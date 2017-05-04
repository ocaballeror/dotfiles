#!/usr/bin/env bats

load ~/.bash_functions

temp="$(mktemp -d)"
cd $temp

@test "Run c" {
	cat > test.c <<EOF
	#include <stdio.h>
	int main() {
	printf ("Hello world\n");
	return 0;
}
EOF

	run brun test.c
	[ "$output" = "Hello world" ]
}

@test "Run cpp" {
	cat > test.cpp <<EOF
	#include <iostream>
	int main() {
	std::cout << "Hello world\n";
	return 0;
}
EOF

	run brun test.c
	[ "$output" = "Hello world" ]
}

@test "Run java" {
	cat > Test.java <<EOF
	public class Test {
	public static void main (String  [] args){
	System.out.println("Hello world");	
}
}
EOF

	run brun test.java
	[ "$output" = "Hello world" ]
}

@test "Run sh" {
	cat > test.sh <<EOF
	echo "Hello world"
EOF	

	run brun test.sh
	[ "$output" = "Hello world" ]
}

@test "Run c with arguments" {
	cat > test.c <<EOF
	#include <stdio.h>
	int main(int argc, char **argv) {
	printf ("%s\n", argv[1]);
	return 0;
}
EOF

	run brun test.c "Hello world"
	[ "$output" = "Hello world" ]
}

@test "Run cpp with arguments" {
	cat > test.cpp <<EOF
	#include <iostream>
	int main(int argc, char **argv) {
	std::cout << argv[1] << std::endl;
	return 0;
}
EOF

	run brun test.c "Hello world"
	[ "$output" = "Hello world" ]
}

@test "Run java with arguments" {
	cat > Test.java <<EOF
	public class Test {
	public static void main (String  [] args){
	System.out.println(args[0]);	
}
}
EOF

	run brun test.java "Hello world"
	[ "$output" = "Hello world" ]
}

@test "Run sh with arguments" {
	cat > test.sh <<EOF
	echo "Hello world"
EOF	

	run brun test.sh "Hello world"
	[ "$output" = "Hello world" ]
}

cd "$HOME"
[ -d "$temp" ] && rm -rf "$temp"
