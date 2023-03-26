/*
 * Memory detection code
 */

#include "boot.h"

static u32 setup_memory_start;
static u32 setup_memory_end;

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

                    if (mmap->addr <= module_start_memory && mmap->len + mmap->addr >= CONFIG_SETUP1_START && mmap->type == E820_RAM) {
                        setup_memory_start = module_start_memory;
                        setup_memory_end = CONFIG_SETUP1_START;
                    }
                }
    if (setup_memory_start != module_start_memory || setup_memory_end != CONFIG_SETUP1_START) {
        puts("can not find memory for setup_memory");
        return 0;
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

/*调用后有可能破坏multiboot协议的信息，需要在此之前进行保存*/
/*只能在detect_memory与save_modules后调用*/
void *malloc(unsigned long size) {
    void* ptr = NULL;
    if (setup_memory_start == 0 || setup_memory_end == 0 || boot_params.setup1.module_start == 0) {
        return ptr;
    }
    if (setup_memory_start == module_start_memory) {
        setup_memory_start = boot_params.setup1.module_start + boot_params.setup1.module_len;
    }
    if (setup_memory_start + size < setup_memory_end) {
        ptr = (void*)setup_memory_start;
        setup_memory_start += size;
    }
    return ptr;
}