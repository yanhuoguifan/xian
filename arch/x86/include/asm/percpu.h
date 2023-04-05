#ifndef _ASM_X86_PERCPU_H
#define _ASM_X86_PERCPU_H

#ifdef __ASSEMBLY__

#ifdef CONFIG_X86_64_SMP
//先不使用SMP特性
#define INIT_PER_CPU_VAR(var)  init_per_cpu__##var
#else
#define INIT_PER_CPU_VAR(var)  var
#endif

#endif /* !__ASSEMBLY__ */

#endif /* _ASM_X86_PERCPU_H */