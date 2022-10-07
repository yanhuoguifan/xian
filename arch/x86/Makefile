# Unified Makefile for i386 and x86_64

# select defconfig based on actual architecture

# BITS is used as extension for files which are available in a 32 bit
# and a 64 bit version to simplify shared Makefiles.
# e.g.: obj-y += foo_$(BITS).o
export BITS

ifeq ($(CONFIG_X86_32),y)
    BITS := 32

    KBUILD_AFLAGS += 
    KBUILD_CFLAGS +=

else
    BITS := 64

    KBUILD_AFLAGS +=
    KBUILD_CFLAGS +=

endif #ifeq ($(CONFIG_X86_32),y)

boot := arch/x86/boot

# Default kernel to build
all: bzImage

# KBUILD_IMAGE specify target image being built
KBUILD_IMAGE := $(boot)/bzImage

bzImage: xian
	$(Q)$(MAKE) $(build)=$(boot) $(KBUILD_IMAGE)