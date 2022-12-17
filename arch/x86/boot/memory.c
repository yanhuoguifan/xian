/*
 * Memory detection code
 */

#include "boot.h"


static int detect_memory_e820(void)
{
    return 0;
}

/*
使用multiboot携带的内存布局数据代替e820调用初始化内存信息,
经查验，两种数据格式兼容
*/

static int detect_memory_multiboot(void)
{
    int count = 0;
    multiboot_memory_map_t *mmap;
    struct e820entry *desc = boot_params.e820_map;

    if (!multiboot_tag_mmap){
        return 0;
    }

    for (mmap = ((struct multiboot_tag_mmap *) multiboot_tag_mmap)->entries;
                (multiboot_uint8_t *) mmap 
                < (multiboot_uint8_t *) multiboot_tag_mmap + multiboot_tag_mmap->size;
                mmap = (multiboot_memory_map_t *) 
                ((unsigned long) mmap
                + ((struct multiboot_tag_mmap *) multiboot_tag_mmap)->entry_size))
                {
                    printf (" base_addr = 0x%x%x,"
                    " length = 0x%x%x, type = 0x%x\n",
                    (unsigned) (mmap->addr >> 32),
                    (unsigned) (mmap->addr & 0xffffffff),
                    (unsigned) (mmap->len >> 32),
                    (unsigned) (mmap->len & 0xffffffff),
                    (unsigned) mmap->type);

                    desc[count].addr = mmap->addr;
                    desc[count].size = mmap->len;
                    desc[count].type = mmap->type; 

                    count++;
                }
    	

	return boot_params.e820_entries = count;
}

int detect_memory(void)
{
	int err = -1;

	if (detect_memory_multiboot() > 0) {
        err = 0;
    }else {
       if (detect_memory_e820() > 0) {
           err = 0;
       }
    }

	return err;
}