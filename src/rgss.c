/**
 * rgss.exe - the standalone rgss, work with rgss.dll
 * compile: gcc -W -Wall -m32 -std=c11 -s -O -o rgss.exe rgss.c
 * usage: rgss file.rb ...ARGV
 *     rgss.exe will try loading "RGSS301.dll" at current path
 * notice: can only get the error message string.
 *     for backtrace, rescue it in ruby
 */

#include <stdio.h>
#include <string.h>
#include <wchar.h>
#include <windows.h>

#define assert_not_equal(fail, value)                    \
    do {                                                 \
        if ((fail) == (value)) errorp(__LINE__, #value); \
    } while (0)

void errorp(int l, char *s) {
    char *m, *b;
    int c = GetLastError();
    FormatMessage(0x1300, 0, c, 0x0400, (char *)&m, 0, 0);
    b = LocalAlloc(0x0040, lstrlen(m) + lstrlen(s) + 40);
    sprintf(b, "%d: %s\nFailed with code %d: %s", l, s, c, m);
    printf("%s", b);
    LocalFree(m);
    LocalFree(b);
    ExitProcess(c);
}

int main(int argc, char **argv) {
    HMODULE lib;
    if (argc == 1) {
        printf("usage: %s file.rb ...ARGV\n", argv[0]);
        exit(0);
    }

    assert_not_equal(0, lib = LoadLibrary("RGSS301.dll"));

    SetConsoleTitle("RGSS Console");
    long unsigned mode;
    HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE);
    GetConsoleMode(hStdout, &mode);
    SetConsoleMode(hStdout, mode | ENABLE_VIRTUAL_TERMINAL_PROCESSING);

#define declare_func(name, ret, ...)            \
    typedef ret(__cdecl *t##name)(__VA_ARGS__); \
    t##name name;                               \
    assert_not_equal(0, name = (t##name)GetProcAddress(lib, #name));

    declare_func(RGSSInitialize3, int);
    declare_func(RGSSEval, int, void *);
    declare_func(RGSSFinalize, int);
    declare_func(RGSSErrorType, wchar_t *);
    declare_func(RGSSErrorMessage, wchar_t *);
#undef declare_func

    HANDLE hFile;
    LPSTR sFile = NULL;
    DWORD n;
    RGSSInitialize3();
    RGSSEval("$: << 'lib'");
    for (int i = 2; i < argc; ++i) {
        int size = strlen(argv[i]) + 10;
        sFile = (LPSTR)realloc(sFile, size + 1);
        sFile[size] = '\0';
        sprintf(sFile, "ARGV << '%s'", argv[i]);
        RGSSEval(sFile);
    }
    hFile = CreateFile(argv[1], GENERIC_READ, 0, NULL, OPEN_EXISTING,
                       FILE_ATTRIBUTE_NORMAL, NULL);
    if (hFile == INVALID_HANDLE_VALUE) {
        printf("Failed to open file: %s\n", argv[1]);
    }
    n = GetFileSize(hFile, NULL);
    sFile = (LPSTR)realloc(sFile, n + 1);
    ReadFile(hFile, sFile, n, &n, NULL);
    CloseHandle(hFile);
    sFile[n] = '\0';
    if (RGSSEval(sFile) == 6) {
        wchar_t *type = RGSSErrorType(), *msg = RGSSErrorMessage();
        while (*(msg++) != '\n') /* strip first two line */
            ;
        wprintf(L"\e[97m%s: (\e[4m%s\e[24m)\e[0m\n", type, ++msg);
    }
    CloseHandle(hFile);
    free(sFile);
    RGSSFinalize();
}
