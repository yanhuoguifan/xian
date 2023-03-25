define set_architecture
    file ./arch/x86/boot/setup0.elf
    add-symbol-file ./arch/x86/boot/setup1.bin
    set architecture i386:x86-64
    target remote localhost:1234
end

set_architecture
