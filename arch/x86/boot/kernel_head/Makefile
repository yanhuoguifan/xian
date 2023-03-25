#
# xian/arch/x86/boot/kernel_head/Makefile
#

targets := setup1.lds setup1.elf head_$(BITS).o misc.o tty.o

KBUILD_CFLAGS := -m$(BITS) -D__KERNEL__ -D_SETUP1 $(XIAN_INCLUDE) -g -Os
#需要禁止sse/sse2和mmx指令集，不然编译器会用优化使用相关指令集，此时还未启用相关特性，会导致内核崩溃
KBUILD_CFLAGS += -ffreestanding -nostdlib -fPIC -mno-sse -mno-sse2 -mno-mmx
#-fPIC是GCC编译器中的一个选项，表示生成与位置无关的代码（Position Independent Code，PIC）。
#生成PIC代码的程序可以在内存中的任何位置加载并执行，而不会受到所在位置的限制。
#会生成相对地址和全局偏移表（Global Offset Table，GOT）等机制，用于在程序运行时解析全局符号（函数、变量等）的地址。在程序启动时，
#会将GOT中的每个全局符号地址都更新为正确的地址。

#System V AMD64 ABI : 前5个整型参数以寄存器传递，按照从左到右的顺序分别存储在%rdi、%rsi、%rdx、%rcx和%r8寄存器中。
#如果函数需要传递更多的整型参数，或传递浮点数参数，则使用栈来传递。
cflags-$(CONFIG_X86_32) := -march=i386
cflags-$(CONFIG_X86_64) := -mcmodel=small
KBUILD_CFLAGS += $(cflags-y)

KBUILD_AFLAGS  := $(KBUILD_CFLAGS) -D__ASSEMBLY__

LDFLAGS := -m elf_$(UTS_MACHINE)
LDFLAGS_setup1.elf := -T
$(obj)/setup1.elf: $(obj)/setup1.lds $(obj)/head_$(BITS).o $(obj)/misc.o $(obj)/tty.o FORCE
	$(call if_changed,ld)