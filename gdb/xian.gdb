source gdb/debug.py

define set_architecture
    set architecture i386:x86-64
end

define add_symbol
    file ./arch/x86/boot/setup0.elf
    add-symbol-file ./arch/x86/boot/setup1.bin
    python add_xian_init_symbol()
    add-symbol-file ./arch/x86/boot/xian.bin
    python AutoDeleteSymbol('arch/x86/kernel/head_64.S:virtual_addresses')
end

set pagination off
set_architecture
add_symbol
target remote localhost:1234
set pagination on