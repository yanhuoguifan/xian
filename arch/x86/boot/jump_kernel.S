
#include <xian/linkage.h>

	.text
	.code32
    
//目的是为了跳到change_mode/head_(bits).S里的
/*
 * void jump_kernel(void* kernel_entry, struct boot_params* boot_params)
 */
GLOBAL(jump_kernel)
	jmpl	*%eax			# Jump to the 32-bit entrypoint
ENDPROC(jump_kernel)