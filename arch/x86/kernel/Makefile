#
# Makefile for the linux kernel.
#


extra-y                := head_$(BITS).o xian.lds xian_head_debug.lds

CPPFLAGS_xian.lds += -U$(UTS_MACHINE)

obj-y			:= touch.o