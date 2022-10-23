# SPDX-License-Identifier: GPL-2.0
#xian_os
#if类缩进用空格实现

VERSION = 0
PATCHLEVEL = 0
SUBLEVEL = 1

KERNELVERSION = $(VERSION)$(if $(PATCHLEVEL),.$(PATCHLEVEL)$(if $(SUBLEVEL),.$(SUBLEVEL)))

export VERSION PATCHLEVEL SUBLEVEL KERNELVERSION

#首先出现的就是-V ，那么make V=1会在构建过程中输出详细的编译信息，第一个ifeq就是检查传递给make的V=n选项。
ifeq ("$(origin V)", "command line")
  KBUILD_VERBOSE = $(V)
endif
ifndef KBUILD_VERBOSE
  KBUILD_VERBOSE = 0
endif

#默认的目标
PHONY := _all
_all:

# Cancel implicit rules on top Makefile
$(CURDIR)/Makefile Makefile: ;

_all: all

srctree		:= $(CURDIR)
objtree		:= $(CURDIR)

export srctree

#获取主机的cpu架构
SUBARCH := $(shell uname -m | sed -e s/i.86/i386/ -e s/sun4u/sparc64/ \
				  -e s/arm.*/arm/ -e s/sa110/arm/ \
				  -e s/s390x/s390/ -e s/parisc64/parisc/ \
				  -e s/ppc.*/powerpc/ -e s/mips.*/mips/ \
				  -e s/sh[234].*/sh/ )

#当外部不指定编译系统架构时，使用主机的架构
ARCH		?= $(SUBARCH)

ifeq ($(ARCH),i386)
        SRCARCH := x86
endif
ifeq ($(ARCH),x86_64)
        SRCARCH := x86
endif

# Where to locate arch specific headers
hdr-arch  := $(SRCARCH)

KCONFIG_CONFIG	?= .config
export KCONFIG_CONFIG

#接下来就要设置一组和编译内核的编译器相关的变量。我们会设置主机的C和C++的编译器及相关配置项
ifneq ($(LLVM),)
HOSTCC	= clang
HOSTCXX	= clang++
else
HOSTCC	= gcc
HOSTCXX	= g++
endif

HOSTCFLAGS   = -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer
HOSTCXXFLAGS = -O2

#然后系统会检查KBUILD_VERBOSE的值，以此来决定quiet和Q的值。
#符号@控制命令的输出，如果它被放在一个命令之前，
ifeq ($(KBUILD_VERBOSE),1)
  quiet =
  Q =
else
  quiet=quiet_
  Q = @
endif

#这条命令的输出将会是CCscripts/mod/empty.o，而不是Compiling….scripts/mod/empty.o
# If the user is running make -s (silent mode), suppress echoing of
# commands

ifneq ($(findstring s,$(MAKEFLAGS)),)
  quiet=silent_
endif

export quiet Q KBUILD_VERBOSE

$(srctree)/scripts/Kbuild.include: ;
include $(srctree)/scripts/Kbuild.include

CONFIG_SHELL := $(shell if [ -x "$$BASH" ]; then echo $$BASH; \
	  else if [ -x /bin/bash ]; then echo /bin/bash; \
	  else echo sh; fi ; fi)

#文件Kbuild或者又叫做KernelBuildSystem是一个用来管理构建内核及其模块的特殊框架。
#kbuild文件的语法与makefile一样。文件scripts/Kbuild.include为kbuild系统提供了一些常规的定义。
#因为我们包含了这个kbuild文件，我们可以看到和不同工具关联的这些变量的定义，
#这些工具会在内核和模块编译过程中被使用（比如链接器、编译器、来自binutils的二进制工具包，等等）：

HOST_LFS_CFLAGS := $(shell getconf LFS_CFLAGS 2>/dev/null)

export KBUILD_USERCFLAGS := -Wall -Wmissing-prototypes -Wstrict-prototypes \
			      -O2 -fomit-frame-pointer -std=gnu89
export KBUILD_USERLDFLAGS :=

KBUILD_HOSTCFLAGS   := $(KBUILD_USERCFLAGS) $(HOST_LFS_CFLAGS) $(HOSTCFLAGS)
KBUILD_HOSTCXXFLAGS := -Wall -O2 $(HOST_LFS_CFLAGS) $(HOSTCXXFLAGS)
KBUILD_HOSTLDFLAGS  := $(HOST_LFS_LDFLAGS) $(HOSTLDFLAGS)
KBUILD_HOSTLDLIBS   := $(HOST_LFS_LIBS) $(HOSTLDLIBS)

# Make variables (CC, etc...)
CPP		= $(CC) -E
ifneq ($(LLVM),)
CC		= clang
LD		= ld.lld
else
CC		= $(CROSS_COMPILE)gcc
LD		= $(CROSS_COMPILE)ld
endif
AS		= $(CROSS_COMPILE)as

# Use XIANINCLUDE when you must reference the include/ directory.
# Needed to be compatible with the O= option
#XIANINCLUDE。他们包含了头文件的路径
XIANINCLUDE    := -I$(srctree)/arch/$(hdr-arch)/include -Iinclude \
                   -include include/generated/autoconf.h

KBUILD_CPPFLAGS := -D__KERNEL__
#-Wall	生成所有警告信息。
KBUILD_AFLAGS   := -D__ASSEMBLY__ -fno-PIE
KBUILD_CFLAGS   := -Wall -Wundef -Werror=strict-prototypes -Wno-trigraphs \
		   -fno-strict-aliasing -fno-common -fshort-wchar -fno-PIE \
		   -Werror=implicit-function-declaration -Werror=implicit-int \
		   -Werror=return-type -Wno-format-security \
		   -std=gnu89
KBUILD_LDFLAGS :=

export ARCH SRCARCH CONFIG_SHELL HOSTCC KBUILD_HOSTCFLAGS HOSTCFLAGS AS LD CC
export CPP 
export HOSTCXX HOSTCXXFLAGS 

export KBUILD_CPPFLAGS NOSTDINC_FLAGS XIANINCLUDE LDFLAGS KBUILD_LDFLAGS
export KBUILD_CFLAGS
export KBUILD_AFLAGS 

# Basic helpers built in scripts/
#目标script_basic的实际操作实际上是通过./scripts/Makefile.build构建子目录 scripts/basic.
#进入到scripts/basic/makefile
PHONY += scripts_basic
scripts_basic:
#编译 ./scripts/basic目录，主要包括 
#fixdep(给.cmd中输出的头文件依赖做修正的,其只有在if_changed_dep，rule_cc_o_c等位置会调用，
	$(Q)$(MAKE) $(build)=scripts/basic
	$(Q)rm -f .tmp_quiet_recordmcount


# To make sure we do not include .config for any of the *config targets
# catch them early, and hand them over to scripts/kconfig/Makefile
# It is allowed to specify more targets when calling make, including
# mixing *config targets and build targets.
# For example 'make oldconfig all'.
# Detect when mixed targets is specified, and make a second invocation
# of make so .config is not included in this case either (for *config).
#确定当前的编译目标是否需要include .config(最终取决于dot-config变量)
# 若当前make的目标包含且仅包含$(no-dot-config-targets)中的目标时(见下)，
#当前编译不需要include .config中的配置项，如help.
# 这里记录的一些目标，是不需要依赖于内核.config即可构建的
no-dot-config-targets := clean mrproper distclean

# 此变量记录当前是否要重新构建.config文件,若当前make指定了[%]config作为目标，就会设置config-targets
config-targets := 0

## dot-config 代表当前的编译目标是否需要引入 .config中的配置项变量，有的目标不需要引入.config就可以编译，如help
dot-config     := 1

# 若当前make仅指定了no-dot-config-targets中的目标(一个或多个)，而没有指定no-dot-config-targets之外的目标，则设置dot-config :=0，
## 代表后续不需要在makefile中包含.config文件中的CONFIG宏定义变量
ifneq ($(filter $(no-dot-config-targets), $(MAKECMDGOALS)),)
	ifeq ($(filter-out $(no-dot-config-targets), $(MAKECMDGOALS)),)
		dot-config := 0
	endif
endif

# 若指定了 %config, 则代表要重建.config
ifneq ($(filter config %config,$(MAKECMDGOALS)),)
    # 那么则需要重新构建config
    config-targets := 1
endif

## 若当前要编译xxxconfig
ifeq ($(config-targets),1)
    # 包含平台相关的makefile
    include $(srctree)/arch/$(SRCARCH)/Makefile

    export KBUILD_DEFCONFIG KBUILD_KCONFIG

    # 这里是config和 %config的构建命令，其依赖于 scripts_basic 
    config: scripts_basic FORCE
		$(Q)mkdir -p include/xian include/config
		$(Q)$(MAKE) $(build)=scripts/kconfig $@

    %config: scripts_basic FORCE
		$(Q)mkdir -p include/xian include/config
		$(Q)$(MAKE) $(build)=scripts/kconfig $@

else
    # 到这里当前的编译目标一定不是xxx_config(否则前面的流程就结束了)

PHONY += scripts
#vmxian-dirs也依赖于第二个目标scripts，它会编译接下来的几个程序：filealias，mk_elfconfig，modpost等等。
scripts: scripts_basic include/config/auto.conf 
	$(Q)$(MAKE) $(build)=$(@)

# Objects we will link into xian / subdirs we need to visit
# 这里是需要连接到xian的目录的变量
#init-y		:= init/

## 此时如果需要使用.config的话，则直接包含auto.conf,将内核的CONFIG配置引入到Makefile的配置中
# include了auto.conf后，内核的配置项变为了Makefile中的变量，
#此后的Makefile中可以直接使用CONFIG_XXX来判断内核配置是否开启了.
ifeq ($(dot-config),1)
    # Read in config
    -include include/config/auto.conf

    # Read in dependencies to all Kconfig* files, make sure to run
    # oldconfig if changes are detected.
    -include include/config/auto.conf.cmd

    # To avoid any implicit rule to kick in, define an empty command
    $(KCONFIG_CONFIG) include/config/auto.conf.cmd: ;

    # If .config is newer than include/config/auto.conf, someone tinkered
    # with it and forgot to run make oldconfig.
    # if auto.conf.cmd is missing then we are probably in a cleaned tree so
    # we execute the config step to be sure to catch updated Kconfig files
    include/config/%.conf: $(KCONFIG_CONFIG) include/config/auto.conf.cmd
	    $(Q)$(MAKE) -f $(srctree)/Makefile syncconfig

else
    # Dummy target needed, because used as prerequisite
    include/config/auto.conf: ;
endif # $(dot-config)

all: xian

include $(srctree)/arch/$(SRCARCH)/Makefile

# Default kernel image to build when no specific target is given.
# KBUILD_IMAGE may be overruled on the command line or
# set in the environment
# Also any assignments in arch/$(ARCH)/Makefile take precedence over
# this default value
export KBUILD_IMAGE ?= vmxian

## 这里过滤掉所有目录字符串尾部的/,也就是说vmxian-dirs全是目录名，但没有 /结尾

vmxian-dirs	:= $(patsubst %/,%,$(filter %/, $(init-y)))

## 将所有的目录%/都替换为 %/built-in.o
init-y		:= $(patsubst %/, %/built-in.o, $(init-y))

vmxian-init := $(init-y)


xian: $(vmxian-init)

#编译各个目录
$(sort $(vmxian-init) ) : $(vmxian-dirs) 

PHONY += $(vmxian-dirs)
#就像我们看到的，vmxian-dirs依赖于两部分：prepare和scripts。
## 这里的make展开如 make build := -f $(srctree)/scripts/Makefile.build obj=init 
## 每一个子目录名都要执行一次此make
$(vmxian-dirs): prepare
	$(Q)$(MAKE) $(build)=$@

PHONY += prepare

prepare1: include/config/auto.conf

archprepare: prepare1 scripts_basic

# All the preparing..
prepare: prepare0

###
# Cleaning is done on three levels.
# make clean     Delete most generated files
#                Leave enough to build external modules
# make mrproper  Delete the current configuration, and all generated files
# make distclean Remove editor backup files, patch leftover files and the like
# clean的操作有三个级别：
#    - make clean: 会删除大部分已生成的文件，只留下编译外部模块必须的文件
#    - make mrproper: 会删除当前的配置文件，和所有生成的文件
#    - make distclean: 删除编译器备份文件,patch上下的文件等.
#   三者是层层递进的，其依赖关系中也可看出这一点:
# Directories & files removed with 'make clean'
CLEAN_DIRS  += $(MODVERDIR)

# Directories & files removed with 'make mrproper'
MRPROPER_DIRS  += include/config usr/include include/generated
MRPROPER_FILES += .config .config.old .version .old_version             \
                  include/xian/version.h                               \

# clean - Delete most, but leave enough to build external modules
#

clean: rm-dirs  := $(CLEAN_DIRS)
clean: rm-files := $(CLEAN_FILES)
clean-dirs := $(addprefix _clean_,$(KBUILD_EXTMOD))

PHONY += $(clean-dirs) clean
$(clean-dirs):
	$(Q)$(MAKE) $(clean)=$(patsubst _clean_%,%,$@)

no-clean-dir ?=-path ./hdisk -prune -o

clean:	rm-dirs := $(MODVERDIR)

clean: $(clean-dirs)
	$(call cmd,rmdirs)
	$(call cmd,rmfiles)
	@find $(KBUILD_EXTMOD) $(RCS_FIND_IGNORE) \
    $(no-clean-dir) \
		\( -name '*.[aios]' -o -name '*.ko' -o -name '.*.cmd' \
		-o -name '*.ko.*' \
		-o -name '*.elf' \
		-o -name '*.dtb' -o -name '*.dtb.S' -o -name '*.dt.yaml' \
		-o -name '*.dwo' -o -name '*.lst' \
		-o -name '*.su' -o -name '*.mod' \
		-o -name '.*.d' -o -name '.*.tmp' -o -name '*.mod.c' \
		-o -name '*.lex.c' -o -name '*.tab.[ch]' \
		-o -name '*.asn1.[ch]' \
		-o -name '*.symtypes' -o -name 'modules.order' \
		-o -name '.tmp_*.o.*' \
		-o -name '*.c.[012]*.*' \
		-o -name '*.ll' \
		-o -name '*.gcno' \) -type f -print | xargs rm -f

# mrproper - Delete all generated files, including .config
#
mrproper: rm-dirs  := $(wildcard $(MRPROPER_DIRS))
mrproper: rm-files := $(wildcard $(MRPROPER_FILES))
mrproper-dirs      := $(addprefix _mrproper_,scripts)

PHONY += $(mrproper-dirs) mrproper archmrproper
$(mrproper-dirs):
	$(Q)$(MAKE) $(clean)=$(patsubst _mrproper_%,%,$@)

mrproper: clean $(mrproper-dirs)
	$(call cmd,rmdirs)
	$(call cmd,rmfiles)

# distclean
#
PHONY += distclean

distclean: mrproper
	@find $(srctree) $(RCS_FIND_IGNORE) \
		\( -name '*.orig' -o -name '*.rej' -o -name '*~' \
		-o -name '*.bak' -o -name '#*#' -o -name '.*.orig' \
		-o -name '.*.rej' -o -size 0 \
		-o -name '*%' -o -name '.*.cmd' -o -name 'core' \) \
		-type f -print | xargs rm -f

quiet_cmd_rmdirs = $(if $(wildcard $(rm-dirs)),CLEAN   $(wildcard $(rm-dirs)))
      cmd_rmdirs = rm -rf $(rm-dirs)

quiet_cmd_rmfiles = $(if $(wildcard $(rm-files)),CLEAN   $(wildcard $(rm-files)))
      cmd_rmfiles = rm -f $(rm-files)

#cmd_file文件将编译命令写入，用于与后面的编译命令比较】
targets := $(wildcard $(sort $(targets)))
cmd_files := $(wildcard .*.cmd $(foreach f,$(targets),$(dir $(f)).$(notdir $(f)).cmd))

ifneq ($(cmd_files),)
  $(cmd_files): ;	# Do not try to update included dependency files
  include $(cmd_files)
endif

endif # #ifeq ($(config-targets),1)

PHONY += FORCE

FORCE:

# Declare the contents of the .PHONY variable as phony.  We keep that
# information in a variable so we can use it in if_changed and friends.
.PHONY: $(PHONY)