# Unified Makefile for i386 and x86_64

# select defconfig based on actual architecture

# BITS is used as extension for files which are available in a 32 bit
# and a 64 bit version to simplify shared Makefiles.
# e.g.: obj-y += foo_$(BITS).o
export BITS

ifeq ($(CONFIG_X86_32),y)
    BITS := 32
    UTS_MACHINE := i386

    KBUILD_AFLAGS += -m32
    KBUILD_CFLAGS += -m32

else
    BITS := 64
    UTS_MACHINE := x86_64

    KBUILD_AFLAGS += -m64
    KBUILD_CFLAGS += -m64

endif #ifeq ($(CONFIG_X86_32),y)

KBUILD_LDFLAGS := -m elf_$(UTS_MACHINE)

#压栈方式：从左到右，rax，rdx，rcx,由-mregparm=3指定
#目标环境是一个独立的环境，没有标准库的支持,由-ffreestanding指定
#链接时不要使用标准系统文件或库：-nostdlib
#进制sse，sse2和mmx指令集：-mno-sse -mno-sse2 -mno-mmx
REALMODE_CFLAGS	:= -m32 -g -Os -march=i386 -mregparm=3 \
                    -ffreestanding -nostdlib -mno-sse -mno-sse2 -mno-mmx
#第三行需要尝试
export REALMODE_CFLAGS

boot := arch/x86/boot

# Default kernel to build
all: bzImage

# KBUILD_IMAGE specify target image being built
KBUILD_IMAGE := $(boot)/bzImage


INSTALL_IMAGE := $(boot)/install


CLEAN_IMAGE := $(boot)/clean


DUBUG_XIAN := $(boot)/debug

bzImage: xian
	$(Q)$(MAKE) $(build)=$(boot) $(KBUILD_IMAGE)

install: bzImage
	$(Q)$(MAKE) $(build)=$(boot) $(INSTALL_IMAGE)

clean: clean_install
clean_install: 
	$(Q)$(MAKE) $(build)=$(boot) $(CLEAN_IMAGE)

debug: install
	$(Q)$(MAKE) $(build)=$(boot) $(DUBUG_XIAN)