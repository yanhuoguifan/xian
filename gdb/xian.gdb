define set_architecture
    file ./arch/x86/boot/setup.elf
    add-symbol-file ./arch/x86/boot/xian.bin
    set architecture i386:x86-64
    target remote localhost:1234
end

set_architecture
