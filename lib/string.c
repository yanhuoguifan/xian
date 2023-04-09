#include <xian/types.h>
#include <xian/string.h>

#ifndef __HAVE_ARCH_MEMSET
/**
 * memset - Fill a region of memory with the given value
 * @s: Pointer to the start of the area.
 * @c: The byte to fill the area with
 * @count: The size of the area.
 *
 * Do not use memset() to access IO space, use memset_io() instead.
 */
 //由于未知原因，x86_64使用O2优化会导致count没有进行递减，强制转成O1优化
__attribute__((optimize("O1")))
void *memset(void *s, int c, size_t count)
{
	char *xs = s;

	while (count--)
		*xs++ = c;
	return s;
}

#endif //__HAVE_ARCH_MEMSET