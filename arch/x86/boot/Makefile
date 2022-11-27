#targets用于读cmd文件
targets		:= setup.elf bzImage

setup-y		+= header.o main.o copy.o printf.o

setup-$(CONFIG_MULTIBOOT2) += multiboot2_parse.o
setup-$(CONFIG_MULTIBOOT1) += multiboot_parse.o

targets += $(setup-y)

SETUP_OBJS = $(addprefix $(obj)/,$(setup-y))

KBUILD_CFLAGS	:= $(REALMODE_CFLAGS) -D_SETUP
KBUILD_AFLAGS	:= $(KBUILD_CFLAGS) -D__ASSEMBLY__

LDFLAGS_setup.elf	:= -m elf_i386 -T
$(obj)/setup.elf: $(src)/setup.ld $(SETUP_OBJS) FORCE
	$(call if_changed,ld)

#生成真正的内核文件，依赖 setup.elf，setup依赖/arch/x86/boot/文件夹下面的文件
$(obj)/bzImage: $(obj)/setup.elf FORCE

.PHONY : $(obj)/install
$(obj)/install: 
	$(shell $(obj)/grub/grub_env.sh xian $(obj)/setup.elf hdisk)

.PHONY : $(obj)/clean
$(obj)/clean:
	$(shell $(obj)/grub/clean_grub_env.sh xian hdisk)

.PHONY : $(obj)/debug
$(obj)/debug: 
	$(shell $(obj)/gdb/debug.sh xian $(obj)/gdb/xian.gdb)