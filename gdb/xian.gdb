define set_architecture
    set architecture i386:x86-64
end

define add_symbol
    file ./arch/x86/boot/setup0.elf
    add-symbol-file ./arch/x86/boot/setup1.bin
    add-symbol-file ./arch/x86/boot/xian.bin -s .data 0x1001000 -s .text 0x1000000 -s .bss 0x1008000
    add-symbol-file ./arch/x86/boot/xian.bin
end

set pagination off
set_architecture
add_symbol
source gdb/debug.py
target remote localhost:1234
set pagination on