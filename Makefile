
rgss.exe: src\rgss.c
	clang -W -Wall -m32 -std=c11 -O -o $@ $^

all: rgss.exe

.PHONY : all
