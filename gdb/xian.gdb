define set 
    file ./arch/x86/boot/setup.elf
    set architecture i386:x86-64
    target remote localhost:1234
end

set
