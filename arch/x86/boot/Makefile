# ROOT_DEV specifies the default root-device when making the image.
# This can be either FLOPPY, CURRENT, /dev/xxxx or empty, in which case
# the default of FLOPPY is used by 'build'.

ROOT_DEV	:= CURRENT

#targets用于读cmd文件
targets		:= setup.elf setup.bin 

setup-y     += header.o main.o copy_c.o printf.o
setup-y     += memory.o tty.o string.o jump_kernel.o
setup-y     += save_modules.o copy_s.o load_kernel.o

setup-$(CONFIG_MULTIBOOT2) += multiboot2_parse.o
setup-$(CONFIG_MULTIBOOT1) += multiboot1_parse.o

targets += $(setup-y)

SETUP_OBJS = $(addprefix $(obj)/,$(setup-y))

KBUILD_CFLAGS	:= $(REALMODE_CFLAGS) -D_SETUP
KBUILD_AFLAGS	:= $(KBUILD_CFLAGS) -D__ASSEMBLY__

#生成的启动文件和内核文件，依赖 setup.elf，setup依赖/arch/x86/boot/文件夹下面的文件
$(obj)/bzImage: $(obj)/setup.bin $(obj)/xian.bin  FORCE
	@echo 'Kernel: $@ is ready' ' (#'`cat .version`')'

$(obj)/xian.bin: $(obj)/kernel_head/xian.elf FORCE
	$(shell ln -f $(obj)/kernel_head/xian.elf $(obj)/xian.bin)

LDFLAGS_setup.elf	:=  -T
$(obj)/setup.elf: $(src)/setup.ld $(SETUP_OBJS) FORCE
	$(call if_changed,ld)

OBJCOPYFLAGS_setup.bin	:= -O binary
$(obj)/setup.bin: $(obj)/setup.elf FORCE
	$(call if_changed,objcopy)

$(obj)/kernel_head/xian.elf: FORCE
	$(Q)$(MAKE) $(build)=$(obj)/kernel_head $@

.PHONY : $(obj)/install
$(obj)/install: 
	$(shell $(obj)/grub/grub_env.sh xian $(obj)/setup.bin $(obj)/xian.bin hdisk 2&>1)

.PHONY : $(obj)/clean
$(obj)/clean:
	$(shell $(obj)/grub/clean_grub_env.sh xian hdisk)

.PHONY : $(obj)/debug
$(obj)/debug: 
	$(shell $(obj)/gdb/debug.sh xian $(obj)/gdb/xian.gdb)