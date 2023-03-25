#include "../tty.c"
#include "misc.h"

void console_init(void)
{
    cursor_y = real_mode->console.cursor_y;
    cursor_x = real_mode->console.cursor_x;
}
