# ROOT_DEV specifies the default root-device when making the image.
# This can be either FLOPPY, CURRENT, /dev/xxxx or empty, in which case
# the default of FLOPPY is used by 'build'.

ROOT_DEV	:= CURRENT

#targets用于读cmd文件
targets		:= setup0.elf setup0.bin 

setup-y     += header.o main.o copy_c.o printf.o
setup-y     += memory.o tty.o string.o jump_setup1.o
setup-y     += save_modules.o copy_s.o load_setup1.o

setup-$(CONFIG_MULTIBOOT2) += multiboot2_parse.o
setup-$(CONFIG_MULTIBOOT1) += multiboot1_parse.o

targets += $(setup-y)

SETUP_OBJS = $(addprefix $(obj)/,$(setup-y))

KBUILD_CFLAGS	:= $(REALMODE_CFLAGS) -D_SETUP
KBUILD_AFLAGS	:= $(KBUILD_CFLAGS) -D__ASSEMBLY__

#生成的启动文件和内核文件，依赖 setup.elf，setup依赖/arch/x86/boot/文件夹下面的文件
$(obj)/bzImage: $(obj)/setup0.bin $(obj)/setup1.bin $(obj)/xian.bin  FORCE
	@echo 'Kernel: $@ is ready' ' (#'`cat .version`')'

$(obj)/setup1.bin: $(obj)/kernel_head/setup1.elf FORCE
	$(shell ln -f $(obj)/kernel_head/setup1.elf $(obj)/setup1.bin)

$(obj)/xian.bin: xian FORCE
	$(shell ln -f xian $(obj)/xian.bin)

LDFLAGS_setup0.elf	:=  -T
$(obj)/setup0.elf: $(src)/setup0.ld $(SETUP_OBJS) FORCE
	$(call if_changed,ld)

OBJCOPYFLAGS_setup0.bin	:= -O binary
$(obj)/setup0.bin: $(obj)/setup0.elf FORCE
	$(call if_changed,objcopy)

$(obj)/kernel_head/setup1.elf: FORCE
	$(Q)$(MAKE) $(build)=$(obj)/kernel_head $@

.PHONY : $(obj)/install
$(obj)/install: 
	$(shell $(obj)/grub/grub_env.sh xian $(obj)/setup0.bin $(obj)/setup1.bin $(obj)/xian.bin hdisk )

.PHONY : $(obj)/clean
$(obj)/clean:
	$(shell $(obj)/grub/clean_grub_env.sh xian hdisk)

.PHONY : $(obj)/debug
$(obj)/debug: 
	$(shell $(obj)/gdb/debug.sh xian $(obj)/gdb/xian.gdb)