#ifndef _ASM_X86_SETUP_H
#define _ASM_X86_SETUP_H

#ifndef __ASSEMBLY__
#include <asm/bootparam.h>
#include <xian/init.h>

#ifndef _SETUP
#ifndef _SETUP1

extern struct boot_params boot_params;

#ifdef __i386__

#else
void __init x86_64_start_kernel(char *real_mode);
void __init x86_64_start_reservations(char *real_mode_data);

#endif /* __i386__ */

#endif /* _SETUP1 */
#endif /* _SETUP */

#endif /* __ASSEMBLY__ */

#endif /* _ASM_X86_SETUP_H */