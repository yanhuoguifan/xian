/*
 * 将模块重定向到1M以上的内存中
 */

#include "boot.h"

void save_module(struct module *module, u32 dst)
{
    if(module->module_start != dst){
        memmove((void*)dst, (void*)module->module_start, module->module_len);
        module->module_start = (__u32)dst;
        printf ("Relocate module at 0x%x-0x%x. Command line %s\n",
            module->module_start,
            module->module_start+module->module_len,
            module->module_name);
    }
}

//注意，调用此函数有可能破坏multiboot协议的信息，需要在此之前进行保存
int save_modules(void)
{
    int save_modules_memory = -1;
    struct e820entry *desc = boot_params.e820_map;
    for (int i = 0; i < boot_params.e820_entries; ++i) {
        if (desc[i].addr <= module_start_memory && desc[i].addr + desc[i].size >= module_start_memory && desc[i].type == E820_RAM) {
            save_modules_memory = i ;
            break;
        }
    }
    if (save_modules_memory == -1){
        puts("can not find memory on module_start_memory\n");
        return -1;
    }
    //启动xian必须将kernel和setup1以modules的方式加载
    if (!multiboot_tag_module[0]){
        puts("can not find kernel\n");
        return -1;
    } else {
        boot_params.kernel.module_start = multiboot_tag_module[0]->mod_start;
        boot_params.kernel.module_len = multiboot_tag_module[0]->mod_end - multiboot_tag_module[0]->mod_start + 1;
        memcpy(boot_params.kernel.module_name,"kernel",strnlen("kernel",sizeof(boot_params.kernel.module_name)));
    }

    if (!multiboot_tag_module[1]){
        puts("can not find setup1\n");
        return -1;
    } else {
        boot_params.setup1.module_start = multiboot_tag_module[1]->mod_start;
        boot_params.setup1.module_len = multiboot_tag_module[1]->mod_end - multiboot_tag_module[1]->mod_start + 1;
        memcpy(boot_params.setup1.module_name,"setup1",strnlen("setup1",sizeof(boot_params.setup1.module_name)));
    }

    struct module *kernel_modlue, *setup1_modlue;
    kernel_modlue = &boot_params.kernel;
    setup1_modlue = &boot_params.setup1;
    
    //pad用于第二个模块的64位对齐
    int pad = (kernel_modlue->module_len + 63) / 64 * 64 - kernel_modlue->module_len;

    //如果原本kernel侵占了setup1需要移动到的地方，则setup1需要拷贝两次
    if(kernel_modlue->module_start > module_start_memory + pad && 
        kernel_modlue->module_start < module_start_memory + kernel_modlue->module_len + pad + setup1_modlue->module_len) {
        if (desc[save_modules_memory].size + desc[save_modules_memory].addr - module_start_memory < 
            kernel_modlue->module_start + kernel_modlue->module_len - module_start_memory + setup1_modlue->module_len) {
            printf("Unable to find enough memory from more than 1M, need %d byte, have %d byte\n",
                kernel_modlue->module_start + kernel_modlue->module_len - module_start_memory + setup1_modlue->module_len,
                desc[save_modules_memory].size + desc[save_modules_memory].addr - module_start_memory);
            return -1;
        }
        save_module(setup1_modlue,kernel_modlue->module_start + kernel_modlue->module_len);
    }
    else {
        if (desc[save_modules_memory].size + desc[save_modules_memory].addr - module_start_memory < 
            kernel_modlue->module_len + pad + setup1_modlue->module_len) {
            printf("Unable to find enough memory from more than 1M, need %d byte, have %d byte\n",
                kernel_modlue->module_len + pad + setup1_modlue->module_len,
                desc[save_modules_memory].size + desc[save_modules_memory].addr - module_start_memory);
            return -1;
        }
        save_module(setup1_modlue,kernel_modlue->module_start + kernel_modlue->module_len + pad);
    }

    save_module(kernel_modlue, module_start_memory);
    save_module(setup1_modlue,kernel_modlue->module_start + kernel_modlue->module_len + pad);

    return 0;
}