define set_architecture
    set architecture i386:x86-64
end

define add_symbol
    file ./arch/x86/boot/setup0.elf
    add-symbol-file ./arch/x86/boot/setup1.bin
    add-symbol-file ./xian_head_debug
    add-symbol-file ./arch/x86/boot/xian.bin
end

set pagination off
set_architecture
add_symbol
target remote localhost:1234