# Make sure load_percpu_segment has no stackprotector
nostackp := -fno-stack-protector
CFLAGS_common.o		:= $(nostackp)\

obj-y			:= common.o