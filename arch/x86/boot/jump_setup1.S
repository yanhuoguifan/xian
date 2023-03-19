
#include <xian/linkage.h>

	.text
	.code32
    
//目的是为了跳到kernel_head/head_(bits).S里的
/*
 * void jump_setup1(void* setup1_entry, struct boot_params* boot_params)
 */
GLOBAL(jump_setup1)
	jmpl	*%eax			# Jump to the 32-bit entrypoint
ENDPROC(jump_setup1)