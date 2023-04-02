#ifndef _XIAN__INIT_TASK_H
#define _XIAN__INIT_TASK_H

/*
 *  INIT_TASK is used to set up the first task table, touch at
 * your own risk!. Base=0, limit=0x1fffff (=2MB)
 */
//暂时为空
#define INIT_TASK(tsk)	\
{}

/* Attach to the init_task data structure for proper alignment */
#define __init_task_data __attribute__((__section__(".data..init_task")))

#endif