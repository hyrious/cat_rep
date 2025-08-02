@echo off
setlocal

call "C:\Program Files\Microsoft Visual Studio\2022\Community\vc\Auxiliary\Build\vcvarsall.bat" x86

cl /LD /Gz /O2 src/rgss_ime.c /link /def:src/rgss_ime.def
del *.exp *.lib *.obj
pedump -E rgss_ime.dll
