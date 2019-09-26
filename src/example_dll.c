#define API extern __declspec(dllexport)

API int __stdcall Add(int a, int b) { return a + b; }
// Compile:
//   gcc [-m32] example_dll.c -shared -s -O -o example_dll.dll -Wl,--kill-at
// Use:
//   Win32API.new('example_dll', 'Add', 'll', 'l').call(3, 5) #=> 8
// Get Pure Binary:
//   gcc [-m32] -c -O -fno-ident example_dll.c
//   objcopy -O binary -j .text example_dll.o example_dll
//   hexdump -C example_dll
//   #=>    8b 44 24 08 03 44 24 04  c2 08 00 90
//   objdump -S example_dll.o
//   #=> 00000000 <_Add@8>:
//          8b 44 24 08             mov    0x8(%esp),%eax
//          03 44 24 04             add    0x4(%esp),%eax
//          c2 08 00                ret    $0x8
// Use:
//   Win32API.new('user32', CallWindowProc', 'pllll', 'l').call [
//     0x8b, 0104, 0044, 8,
//     0x03, 0104, 0044, 4,
//     0xc2,         16, 0
//   ].pack('C*'), 3, 5, 0, 0
