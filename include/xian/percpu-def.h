#ifndef _XIAN_PERCPU_DEFS_H
#define _XIAN_PERCPU_DEFS_H

#include<xian/compiler.h>

//暂时置空
#define __PCPU_ATTRS(sec)	
#define PER_CPU_DEF_ATTRIBUTES

#define DECLARE_PER_CPU_SECTION(type, name, sec)			\
	extern __PCPU_ATTRS(sec) type name

#define DEFINE_PER_CPU_SECTION(type, name, sec)				\
	__PCPU_ATTRS(sec) PER_CPU_DEF_ATTRIBUTES			\
	type name


#define DECLARE_PER_CPU_PAGE_ALIGNED(type, name)			\
	DECLARE_PER_CPU_SECTION(type, name, "..page_aligned")		\
	__aligned(PAGE_SIZE)

#define DEFINE_PER_CPU_PAGE_ALIGNED(type, name)				\
	DEFINE_PER_CPU_SECTION(type, name, "..page_aligned")		\
	__aligned(PAGE_SIZE)

#endif /* _XIAN_PERCPU_DEFS_H */