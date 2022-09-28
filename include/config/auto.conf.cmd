deps_config := \
	init/Kconfig \
	arch/x86/Kconfig

include/config/auto.conf: \
	$(deps_config)

ifneq "$(ARCH)" "x86_64"
include/config/auto.conf: FORCE
endif

$(deps_config): ;
