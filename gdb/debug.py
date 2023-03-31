import gdb

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

AutoDeleteSymbol('arch/x86/kernel/head_64.S:virtual_addresses')