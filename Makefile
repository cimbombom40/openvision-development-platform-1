#!/usr/bin/make -f

# Adjust according to the number CPU cores to use for parallel build.
# Default: Number of processors in /proc/cpuinfo, if present, or 1.
NR_CPU := $(shell [ -f /proc/cpuinfo ] && grep -c '^processor\s*:' /proc/cpuinfo || echo 1)
BB_NUMBER_THREADS ?= $(NR_CPU)
PARALLEL_MAKE ?= -j $(NR_CPU)

XSUM ?= md5sum

BUILD_DIR = $(CURDIR)/build
TOPDIR = $(BUILD_DIR)
DL_DIR = $(CURDIR)/sources
SSTATE_DIR = $(TOPDIR)/sstate-cache
TMPDIR = $(TOPDIR)/tmp
DEPDIR = $(TOPDIR)/.deps

BBLAYERS ?= \
	$(CURDIR)/meta-openembedded/meta-oe \
	$(CURDIR)/meta-openembedded/meta-filesystems \
	$(CURDIR)/meta-openembedded/meta-multimedia \
	$(CURDIR)/meta-openembedded/meta-networking \
	$(CURDIR)/meta-openembedded/meta-python \
	$(CURDIR)/openembedded-core/meta \
	$(CURDIR)/meta-openvision \
	$(CURDIR)/meta-amiko \
	$(CURDIR)/meta-ax \
	$(CURDIR)/meta-azbox \
	$(CURDIR)/meta-beyonwiz \
	$(CURDIR)/meta-blackbox \
	$(CURDIR)/meta-broadmedia \
	$(CURDIR)/meta-ceryon \
	$(CURDIR)/meta-clap \
	$(CURDIR)/meta-cube \
	$(CURDIR)/meta-dags \
	$(CURDIR)/meta-dinobot \
	$(CURDIR)/meta-dream \
	$(CURDIR)/meta-ebox \
	$(CURDIR)/meta-edision \
	$(CURDIR)/meta-entwopia \
	$(CURDIR)/meta-formuler \
	$(CURDIR)/meta-gfutures \
	$(CURDIR)/meta-gigablue \
	$(CURDIR)/meta-hypercube \
	$(CURDIR)/meta-ini \
	$(CURDIR)/meta-ixuss \
	$(CURDIR)/meta-linkdroid \
	$(CURDIR)/meta-maxytec \
	$(CURDIR)/meta-minix \
	$(CURDIR)/meta-octagon \
	$(CURDIR)/meta-odin \
	$(CURDIR)/meta-odroid \
	$(CURDIR)/meta-protek \
	$(CURDIR)/meta-raspberrypi \
	$(CURDIR)/meta-sh4 \
	$(CURDIR)/meta-tiviar \
	$(CURDIR)/meta-tripledot \
	$(CURDIR)/meta-uclan \
	$(CURDIR)/meta-vuplus \
	$(CURDIR)/meta-wetek \
	$(CURDIR)/meta-xcore \
	$(CURDIR)/meta-xp \
	$(CURDIR)/meta-xtrend \
	$(CURDIR)/meta-zgemma	

CONFFILES = \
	$(TOPDIR)/env.source \
	$(TOPDIR)/conf/openvision.conf \
	$(TOPDIR)/conf/bblayers.conf \
	$(TOPDIR)/conf/local.conf \
	$(TOPDIR)/conf/site.conf

CONFDEPS = \
	$(DEPDIR)/.env.source.$(BITBAKE_ENV_HASH) \
	$(DEPDIR)/.openvision.conf.$(OPENVISION_CONF_HASH) \
	$(DEPDIR)/.bblayers.conf.$(BBLAYERS_CONF_HASH) \
	$(DEPDIR)/.local.conf.$(LOCAL_CONF_HASH)

GIT ?= git
GIT_REMOTE := $(shell $(GIT) remote)
GIT_USER_NAME := $(shell $(GIT) config user.name)
GIT_USER_EMAIL := $(shell $(GIT) config user.email)
GIT_BRANCH := $(shell $(GIT) symbolic-ref -q --short HEAD)

hash = $(shell echo $(1) | $(XSUM) | awk '{print $$1}')

.DEFAULT_GOAL := all
all: init
	@echo
	@echo "Openembedded for the Open Vision $(GIT_BRANCH) environment has been initialized"
	@echo "properly. Now you can start building your image, by doing either:"
	@echo
	@echo " MACHINE=... make image"
	@echo
	@echo "	or:"
	@echo
	@echo " cd $(BUILD_DIR)"
	@echo " source env.source"
	@echo " MACHINE=... bitbake openvision-enigma2-image"
	@echo
	@echo "	or, if you want to build not just the image, but the optional packages in the feed as well:"
	@echo
	@echo " MACHINE=... make feed"
	@echo "	or:"
	@echo " MACHINE=... bitbake openvision-enigma2-feed"
	@echo

$(BBLAYERS):
	[ -d $@ ] || $(MAKE) $(MFLAGS) update

initialize: init

init: $(BBLAYERS) $(CONFFILES)

image: init
	@echo 'Building image for $(MACHINE)$(DMTYPE)'
	@. $(TOPDIR)/env.source && cd $(TOPDIR) && bitbake openvision-enigma2-image

feed: init
	@echo 'Building feed for $(MACHINE)$(DMTYPE)'
	@. $(TOPDIR)/env.source && cd $(TOPDIR) && bitbake openvision-enigma2-feed

update:
	@echo 'Updating Git repositories...'
	@HASH=`$(XSUM) $(MAKEFILE_LIST)`; \
	if [ -n "$(GIT_REMOTE)" ]; then \
		$(GIT) pull --ff-only || $(GIT) pull --rebase; \
	fi; \
	if [ "$$HASH" != "`$(XSUM) $(MAKEFILE_LIST)`" ]; then \
		echo 'Makefile changed. Restarting...'; \
		$(MAKE) $(MFLAGS) --no-print-directory $(MAKECMDGOALS); \
	else \
		$(GIT) submodule sync && \
		$(GIT) submodule update --init && \
		echo "The Open Vision OE is now up-to-date."; \
	fi

.PHONY: all image init initialize update usage

BITBAKE_ENV_HASH := $(call hash, \
	'BITBAKE_ENV_VERSION = "0"' \
	'CURDIR = "$(CURDIR)"' \
	)

$(TOPDIR)/env.source: $(DEPDIR)/.env.source.$(BITBAKE_ENV_HASH)
	@echo 'Generating $@'
	@echo 'export BB_ENV_EXTRAWHITE="MACHINE DMTYPE"' > $@
	@echo 'export MACHINE' >> $@
	@echo 'export DMTYPE' >> $@
	@echo 'export PATH=$(CURDIR)/openembedded-core/scripts:$(CURDIR)/bitbake/bin:$${PATH}' >> $@

OPENVISION_CONF_HASH := $(call hash, \
	'OPENVISION_CONF_VERSION = "1"' \
	'CURDIR = "$(CURDIR)"' \
	'BB_NUMBER_THREADS = "$(BB_NUMBER_THREADS)"' \
	'PARALLEL_MAKE = "$(PARALLEL_MAKE)"' \
	'DL_DIR = "$(DL_DIR)"' \
	'SSTATE_DIR = "$(SSTATE_DIR)"' \
	'TMPDIR = "$(TMPDIR)"' \
	)

$(TOPDIR)/conf/openvision.conf: $(DEPDIR)/.openvision.conf.$(OPENVISION_CONF_HASH)
	@echo 'Generating $@'
	@test -d $(@D) || mkdir -p $(@D)
	@echo 'SSTATE_DIR = "$(SSTATE_DIR)"' >> $@
	@echo 'TMPDIR = "$(TMPDIR)"' >> $@
	@echo 'BB_GENERATE_MIRROR_TARBALLS = "0"' >> $@
	@echo 'BBINCLUDELOGS = "yes"' >> $@
	@echo 'CONF_VERSION = "1"' >> $@
	@echo 'DISTRO = "openvision"' >> $@
	@echo 'EXTRA_IMAGE_FEATURES = "debug-tweaks"' >> $@
	@echo 'USER_CLASSES = "buildstats"' >> $@

LOCAL_CONF_HASH := $(call hash, \
	'LOCAL_CONF_VERSION = "0"' \
	'CURDIR = "$(CURDIR)"' \
	'TOPDIR = "$(TOPDIR)"' \
	)

$(TOPDIR)/conf/local.conf: $(DEPDIR)/.local.conf.$(LOCAL_CONF_HASH)
	@echo 'Generating $@'
	@test -d $(@D) || mkdir -p $(@D)
	@echo 'TOPDIR = "$(TOPDIR)"' > $@
	@echo 'require $(TOPDIR)/conf/openvision.conf' >> $@

$(TOPDIR)/conf/site.conf: $(CURDIR)/site.conf
	@ln -s ../../site.conf $@

$(CURDIR)/site.conf:
	@echo 'SCONF_VERSION = "1"' >> $@
	@echo 'BB_NUMBER_THREADS = "$(BB_NUMBER_THREADS)"' >> $@
	@echo 'PARALLEL_MAKE = "$(PARALLEL_MAKE)"' >> $@
	@echo 'BUILD_OPTIMIZATION = "-O2 -pipe"' >> $@
	@echo 'DL_DIR = "$(DL_DIR)"' >> $@
	@echo 'INHERIT += "rm_work"' >> $@

BBLAYERS_CONF_HASH := $(call hash, \
	'BBLAYERS_CONF_VERSION = "0"' \
	'CURDIR = "$(CURDIR)"' \
	'BBLAYERS = "$(BBLAYERS)"' \
	)

$(TOPDIR)/conf/bblayers.conf: $(DEPDIR)/.bblayers.conf.$(BBLAYERS_CONF_HASH)
	@echo 'Generating $@'
	@test -d $(@D) || mkdir -p $(@D)
	@echo 'LCONF_VERSION = "5"' > $@
	@echo 'BBPATH = "$${TOPDIR}"' >> $@
	@echo 'BBFILES = ""' >> $@
	@echo 'BBLAYERS = "$(BBLAYERS)"' >> $@

$(CONFDEPS):
	@test -d $(@D) || mkdir -p $(@D)
	@$(RM) $(basename $@).*
	@touch $@

ifeq ($(MACHINE),dm7020hdv2)
MACHINE=dm7020hd
DMTYPE=v2
endif
export DMTYPE
