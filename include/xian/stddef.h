#ifndef _LINUX_STDDEF_H
#define _LINUX_STDDEF_H

#undef NULL
//__cplusplus被c++定义
#if defined(__cplusplus)
#define NULL 0
#else
#define NULL ((void *)0)
#endif

#endif