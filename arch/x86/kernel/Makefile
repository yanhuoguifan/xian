#
# Makefile for the linux kernel.
#


extra-y                := head_$(BITS).o xian.lds

CPPFLAGS_xian.lds += -U$(UTS_MACHINE)

obj-y			:= touch.o