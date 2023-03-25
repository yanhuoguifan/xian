#ifndef KERNEL_HEAD_MM_H
#define KERNEL_HEAD_MM_H

#ifdef STATIC

/* Code active when included from pre-boot environment: */

/*
 * Some architectures want to ensure there is no local data in their
 * pre-boot environment, so that data can arbitrarily relocated (via
 * GOT references).  This is achieved by defining STATIC_RW_DATA to
 * be null.
 */

#ifndef STATIC_RW_DATA
#define STATIC_RW_DATA static
#endif

/* A trivial malloc implementation, adapted from
 *  malloc by Hannu Savolainen 1993 and Matthias Urlichs 1994
 */
STATIC_RW_DATA unsigned long malloc_ptr;
STATIC_RW_DATA int malloc_count;

static void *malloc(int size)
{
	void *p;

	if (size < 0)
		return NULL;
	if (!malloc_ptr)
		malloc_ptr = free_mem_ptr;

	malloc_ptr = (malloc_ptr + 3) & ~3;     /* Align */

	p = (void *)malloc_ptr;
	malloc_ptr += size;

	if (free_mem_end_ptr && malloc_ptr >= free_mem_end_ptr)
		return NULL;

	malloc_count++;
	return p;
}

#endif /* STATIC */

#endif /* KERNEL_HEAD_MM_H */