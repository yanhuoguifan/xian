OUTPUT_ARCH(i386:x86-64)
ENTRY(startup_64)
SECTIONS
{
 . = 0;
 .head.text : {
  _head = . ;
  _ehead = . ;
 }
 .text : {
  _text = .;
  *(.text)
  *(.text.*)
  _etext = . ;
 }
 .rodata : {
  _rodata = . ;
  *(.rodata)
  *(.rodata.*)
  _erodata = . ;
 }
 .data : {
  _data = . ;
  *(.data)
  *(.data.*)
  _edata = . ;
 }
 .bss : {
  _bss = . ;
  *(.bss)
  *(.bss.*)
  *(COMMON)
  . = ALIGN(8);
  _ebss = .;
 }
 _end = .;
}
