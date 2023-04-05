#
# Makefile for the linux kernel.
#


extra-y           := head_$(BITS).o head$(BITS).o init_task.o xian.lds

CPPFLAGS_xian.lds += -U$(UTS_MACHINE)

obj-y			  := setup.o

obj-y			  += cpu/