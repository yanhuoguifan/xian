#include "boot.h"

struct multiboot_tag_mmap *multiboot_tag_mmap;
struct multiboot_tag_module *(multiboot_tag_module[2]);

int multiboot_save () {
	struct multiboot_tag *tag;
    
    if (boot_params.hdr.multiboot_magic != MULTIBOOT2_BOOTLOADER_MAGIC) {
        printf ("Invalid magic number: 0x\n", (unsigned) boot_params.hdr.multiboot_magic);
        return -1;
    }

    if (boot_params.hdr.multiboot_addr & 7) {
        printf ("Unaligned mbi: 0x%x\n", boot_params.hdr.multiboot_addr);
        return -1;
    }

	for (tag = (struct multiboot_tag *)(boot_params.hdr.multiboot_addr + 8);
		tag->type != MULTIBOOT_TAG_TYPE_END;
		tag = (struct multiboot_tag *)((multiboot_uint8_t *)tag + ((tag->size + 7) & ~7))) {
        printf ("Tag 0x%x, Size 0x%x\n", tag->type, tag->size);
        switch (tag->type) {
        case MULTIBOOT_TAG_TYPE_CMDLINE:
            printf ("Command line = %s\n",
                ((struct multiboot_tag_string *) tag)->string);
            break;
        case MULTIBOOT_TAG_TYPE_BOOT_LOADER_NAME:
            printf ("Boot loader name = %s\n",
                ((struct multiboot_tag_string *) tag)->string);
            break;
        case MULTIBOOT_TAG_TYPE_MODULE:
            printf ("Module at 0x%x-0x%x. Command line %s\n",
                ((struct multiboot_tag_module *) tag)->mod_start,
                ((struct multiboot_tag_module *) tag)->mod_end,
                ((struct multiboot_tag_module *) tag)->cmdline);
            //只需要存储两个moudle，一个是kernel，一个是setup1
            if(!strcmp(((struct multiboot_tag_module *) tag)->cmdline,"kernel")) 
                multiboot_tag_module[0] = (struct multiboot_tag_module *) tag;
            if(!strcmp(((struct multiboot_tag_module *) tag)->cmdline,"setup1"))
                multiboot_tag_module[1] = (struct multiboot_tag_module *) tag;
            break;
        case MULTIBOOT_TAG_TYPE_BASIC_MEMINFO:
            printf ("mem_lower = %uKB, mem_upper = %uKB\n",
                ((struct multiboot_tag_basic_meminfo *) tag)->mem_lower,
                ((struct multiboot_tag_basic_meminfo *) tag)->mem_upper);
            break;
        case MULTIBOOT_TAG_TYPE_BOOTDEV:
            printf ("Boot device 0x%x,%u,%u\n",
                ((struct multiboot_tag_bootdev *) tag)->biosdev,
                ((struct multiboot_tag_bootdev *) tag)->slice,
                ((struct multiboot_tag_bootdev *) tag)->part);
            break;
        
        //可寻址的物理内存空间，需要保存
        case MULTIBOOT_TAG_TYPE_MMAP: {
            multiboot_tag_mmap = (struct multiboot_tag_mmap *) tag;
            }
            break;
        //MULTIBOOT_TAG_TYPE_FRAMEBUFFER也是一块显存，
        //下面会对角渲染出一条蓝线，暂时注释
        case MULTIBOOT_TAG_TYPE_FRAMEBUFFER: {
            /*
            multiboot_uint32_t color;
            unsigned i;
            struct multiboot_tag_framebuffer *tagfb
                = (struct multiboot_tag_framebuffer *) tag;
            //fb是一块显存，后面有需要再用
            void *fb = (void *) (unsigned long) tagfb->common.framebuffer_addr;
            switch (tagfb->common.framebuffer_type) {
            case MULTIBOOT_FRAMEBUFFER_TYPE_INDEXED: {
                unsigned best_distance, distance;
                struct multiboot_color *palette;
            
                palette = tagfb->framebuffer_palette;

                color = 0;
                best_distance = 4*256*256;
            
                for (i = 0; i < tagfb->framebuffer_palette_num_colors; i++) {
                    distance = (0xff - palette[i].blue) 
                    * (0xff - palette[i].blue)
                    + palette[i].red * palette[i].red
                    + palette[i].green * palette[i].green;
                    if (distance < best_distance) {
                        color = i;
                        best_distance = distance;
                    }
                }
            }
                break;

            case MULTIBOOT_FRAMEBUFFER_TYPE_RGB:
                color = ((1 << tagfb->framebuffer_blue_mask_size) - 1) 
                  << tagfb->framebuffer_blue_field_position;
                break;

            case MULTIBOOT_FRAMEBUFFER_TYPE_EGA_TEXT:
                color = '\\' | 0x0100;
                break;

            default:
                color = 0xffffffff;
                break;
            }
            
            for (i = 0; i < tagfb->common.framebuffer_width
                   && i < tagfb->common.framebuffer_height; i++) {
                switch (tagfb->common.framebuffer_bpp) {
                case 8: {
                    multiboot_uint8_t *pixel = fb
                    + tagfb->common.framebuffer_pitch * i + i;
                    *pixel = color;
                }
                    break;
                
                case 15:
                case 16:{
                    multiboot_uint16_t *pixel
                    = fb + tagfb->common.framebuffer_pitch * i + 2 * i;
                    *pixel = color;
                }
                    break;
                case 24: {
                    multiboot_uint32_t *pixel
                    = fb + tagfb->common.framebuffer_pitch * i + 3 * i;
                    *pixel = (color & 0xffffff) | (*pixel & 0xff000000);
                }
                    break;

                case 32: {
                    multiboot_uint32_t *pixel
                    = fb + tagfb->common.framebuffer_pitch * i + 4 * i;
                    *pixel = color;
                }
                    break;
                }
            }
            break;
            */
        }

        }
	}
	tag = (struct multiboot_tag *)((multiboot_uint8_t *)tag + ((tag->size + 7) & ~7));
	printf("Total mbi size 0x%x\n", (unsigned)tag - boot_params.hdr.multiboot_addr);

    return 0;
}