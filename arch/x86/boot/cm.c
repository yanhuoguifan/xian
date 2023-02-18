#include "boot.h"

void relocate_kernel(void)
{
    
}

void go_to_change_mode(void)
{
    relocate_kernel();
    change_mode_jump(boot_params.hdr.code32_start);
}