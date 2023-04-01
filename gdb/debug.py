import gdb
import os

class AutoDeleteSymbol(gdb.Breakpoint):
    def __init__(self, spec):
        super(AutoDeleteSymbol, self).__init__(spec, internal=True)
        self.symbols_deleted = False

    def stop(self):
        if not self.symbols_deleted:
            #使用空的symbol-file将之前的符号表删除
            gdb.execute('symbol-file')
            #再次使用symbol-file加载xian符号表
            gdb.execute('symbol-file ./arch/x86/boot/xian.bin')
            self.symbols_deleted = True
        return False

def add_xian_init_symbol():
    xian_program_head = os.popen("objdump -h xian").read()
    target_segments = [".bss", ".data", ".text"]
    target_segments_address = "add-symbol-file ./arch/x86/boot/xian.bin"
    for line in xian_program_head.splitlines():
        for target_segment in target_segments:
            if target_segment in line:
                target_segment_address = line.split()[4]
                target_segments_address += " -s " + target_segment +  " 0x" + target_segment_address
    gdb.execute(target_segments_address)


