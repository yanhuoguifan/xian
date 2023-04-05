/*
 *  prepare to run common code
 *
 *  Copyright (C) 2000 Andrea Arcangeli <andrea@suse.de> SuSE
 */

#include <xian/init.h>
#include <xian/string.h>

#include <asm/setup.h>
#include <asm/page.h>

static void __init copy_bootdata(char *real_mode_data)
{
	memcpy(&boot_params, real_mode_data, sizeof boot_params);
}

void __init x86_64_start_kernel(char * real_mode_data)
{   
    x86_64_start_reservations(real_mode_data);
    //这里不应该return，不过即使return也会命中bad_address
}

void __init x86_64_start_reservations(char *real_mode_data)
{
    copy_bootdata(__va(real_mode_data));
}