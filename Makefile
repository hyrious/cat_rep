
.PHONY : all main

all: rgss.exe rgss_ime.dll

rgss.exe: src\rgss.c
	clang -W -Wall -m32 -std=c11 -O -o $@ $^

rgss_ime.dll: src\rgss_ime.c src\rgss_ime.def
	make_rgss_ime

main:
	rgss run_main.rb
