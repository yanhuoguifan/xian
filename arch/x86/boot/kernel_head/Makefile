#
# xian/arch/x86/boot/change_mode/Makefile
#

targets := xian.lds xian.elf head_$(BITS).o 

KBUILD_CFLAGS := -m$(BITS) -D__KERNEL__ $(XIAN_INCLUDE) -g -Os
KBUILD_CFLAGS += -ffreestanding -nostdlib
cflags-$(CONFIG_X86_32) := -march=i386
KBUILD_CFLAGS += $(cflags-y)

KBUILD_AFLAGS  := $(KBUILD_CFLAGS) -D__ASSEMBLY__

LDFLAGS := -m elf_$(UTS_MACHINE)
LDFLAGS_xian.elf := -T
$(obj)/xian.elf: $(obj)/xian.lds $(obj)/head_$(BITS).o FORCE
	$(call if_changed,ld)