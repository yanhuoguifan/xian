# Unified Makefile for i386 and x86_64

# select defconfig based on actual architecture

boot := arch/x86/boot

# Default kernel to build
all: bzImage

# KBUILD_IMAGE specify target image being built
KBUILD_IMAGE := $(boot)/bzImage

bzImage: xian
	$(Q)$(MAKE) $(build)=$(boot) $(KBUILD_IMAGE)