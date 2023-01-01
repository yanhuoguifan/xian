# ROOT_DEV specifies the default root-device when making the image.
# This can be either FLOPPY, CURRENT, /dev/xxxx or empty, in which case
# the default of FLOPPY is used by 'build'.

ROOT_DEV	:= CURRENT

#targets用于读cmd文件
targets		:= setup.elf bzImage

setup-y         += header.o main.o copy.o printf.o
setup-y     += memory.o tty.o string.o

setup-$(CONFIG_MULTIBOOT2) += multiboot2_parse.o
setup-$(CONFIG_MULTIBOOT1) += multiboot1_parse.o

targets += $(setup-y)

SETUP_OBJS = $(addprefix $(obj)/,$(setup-y))

KBUILD_CFLAGS	:= $(REALMODE_CFLAGS) -D_SETUP
KBUILD_AFLAGS	:= $(KBUILD_CFLAGS) -D__ASSEMBLY__

quiet_cmd_image = BUILD   $@
cmd_image = $(obj)/tools/build $(obj)/setup.bin $(obj)/change_mode/xian \
	$(ROOT_DEV) > $@

#生成真正的内核文件，依赖 setup.elf，setup依赖/arch/x86/boot/文件夹下面的文件
$(obj)/bzImage: $(obj)/setup.bin 

LDFLAGS_setup.elf	:= -m elf_i386 -T
$(obj)/setup.elf: $(src)/setup.ld $(SETUP_OBJS) FORCE
	$(call if_changed,ld)

OBJCOPYFLAGS_setup.bin	:= -O binary
$(obj)/setup.bin: $(obj)/setup.elf FORCE
	$(call if_changed,objcopy)

$(obj)/change_mode/xian: FORCE
	$(Q)$(MAKE) $(build)=$(obj)/change_mode $@

.PHONY : $(obj)/install
$(obj)/install: 
	$(shell $(obj)/grub/grub_env.sh xian $(obj)/setup.bin hdisk)

.PHONY : $(obj)/clean
$(obj)/clean:
	$(shell $(obj)/grub/clean_grub_env.sh xian hdisk)

.PHONY : $(obj)/debug
$(obj)/debug: 
	$(shell $(obj)/gdb/debug.sh xian $(obj)/gdb/xian.gdb)