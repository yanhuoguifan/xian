cmd_scripts/kconfig/symbol.o := gcc -Wp,-MMD,scripts/kconfig/.symbol.o.d_ -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer -std=gnu89  -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer     -c -o scripts/kconfig/symbol.o scripts/kconfig/symbol.c

source_scripts/kconfig/symbol.o := scripts/kconfig/symbol.c

deps_scripts/kconfig/symbol.o := \
  scripts/kconfig/lkc.h \
    $(wildcard include/config/prefix.h) \
  scripts/kconfig/expr.h \
  scripts/kconfig/list.h \
  scripts/kconfig/lkc_proto.h \

scripts/kconfig/symbol.o: $(deps_scripts/kconfig/symbol.o)

$(deps_scripts/kconfig/symbol.o):
