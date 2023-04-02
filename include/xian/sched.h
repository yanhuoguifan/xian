#ifndef _XIAN_SCHED_H
#define _XIAN_SCHED_H

#include <xian/thread_info.h>

#include <asm/page.h>

struct task_struct {
    int zero[1000];//暂时使用zero填充
};

union thread_union {
    //暂时不引入thread_info
	//struct thread_info thread_info;
	unsigned long stack[THREAD_SIZE/sizeof(long)];
};

extern struct task_struct init_task;

#endif