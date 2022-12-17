#ifndef MULTIBOOT_H
#define MULTIBOOT_H

#ifdef CONFIG_MULTIBOOT2

#include <asm/multiboot2.h>

#elif CONFIG_MULTIBOOT1

#include <asm/multiboot1.h>

#endif

#endif