#include "boot.h"

void *memmove(void *dst, void *src, size_t len)
{
    int addr_gap = (int)dst - (int)src;
    if (addr_gap < 0)
        addr_gap = -addr_gap;
    if (addr_gap <= len) 
        return memcpy(dst, src, len);
    if ((int)dst < (int)src) {
        for (int i = 0; i < len ; ++i) {
            *((char*)dst + i) = *((char*)src + i);
        }
    } else {
        for (int i = len - 1; i >= 0 ; --i) {
            *((char*)dst + i) = *((char*)src + i);
        }
    }
    return dst;
}