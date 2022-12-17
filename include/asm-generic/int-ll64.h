/*
 * asm-generic/int-ll64.h
 *
 * Integer declarations for architectures which use "long long"
 * for 64-bit types.
 */

#ifndef _ASM_GENERIC_INT_LL64_H
#define _ASM_GENERIC_INT_LL64_H

#ifndef __ASSEMBLY__

typedef unsigned char __u8;

typedef unsigned int __u32;

#ifdef __GNUC__
__extension__ typedef unsigned long long __u64;
#else
typedef unsigned long long __u64;
#endif

#endif /* __ASSEMBLY__ */

#ifdef __KERNEL__

#ifndef __ASSEMBLY__

typedef unsigned char u8;

typedef unsigned short u16;

#endif /* __ASSEMBLY__ */

#endif /* __KERNEL__ */

#endif /* _ASM_GENERIC_INT_LL64_H */