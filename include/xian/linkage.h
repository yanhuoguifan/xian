#ifndef _XIAN_LINKAGE_H
#define _XIAN_LINKAGE_H

#include <asm/linkage.h>

#ifdef __ASSEMBLY__

#ifndef END
#define END(name) \
  .size name, .-name
#endif

/* If symbol 'name' is treated as a subroutine (gets called, and returns)
 * then please use ENDPROC to mark 'name' as STT_FUNC for the benefit of
 * static analysis tools such as stack depth analyzer.
 */
#ifndef ENDPROC
#define ENDPROC(name) \
  .type name, @function; \
  END(name)
#endif 

#endif /* end __ASSEMBLY__ */

#endif /* end _XIAN_LINKAGE_H */