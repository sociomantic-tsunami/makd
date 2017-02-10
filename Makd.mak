# This file is based on:
# http://git.llucax.com.ar/w/software/makeit.git
#
# Copyright 2008-2011 Integratech S.A.
# Copyright 2011-2014 Leandro Lucarella.
# Copyright 2014-2016 Sociomantic Labs GmbH.
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE or copy at http://www.boost.org/LICENSE_1_0.txt)

ifndef Makd.mak.included
Makd.mak.included := 1

# This variable should be provided by the Makefile that include us (if needed):
# S should be sub-directory where the current makefile is, relative to $T.

# Use the git top-level directory by default
T ?= $(shell git rev-parse --show-toplevel)
# Use absolute paths to avoid problems with automatic dependencies when
# building from subdirectories
T := $(abspath $T)
export MAKD_TOPDIR := $T

# Name of the current directory, relative to $T
R := $(subst $T,,$(patsubst $T/%,%,$(CURDIR)))

# Project name defaults on the name of the top-dir
PROJECT_NAME ?= $(shell basename $T)

# Define the valid flavors
VALID_FLAVORS := devel production

# Flavor (variant), can be defined by the user in Config.mak
F ?= devel

# Directory where all the source files are expected (must be a relative paths,
# use "." for the current directory)
SRC = src

# Directory were this makefile is located (this must be done BEFORE including
# any other Makefile)
MAKD_PATH := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
export MAKD_PATH

# Directory where the FPM package definition files are stored.
PKG := $T/pkg

# Load top-level directory project configuration
-include $T/Config.mak

# Load top-level directory local configuration
-include $T/Config.local.mak

# Check flavours
FLAVOR_IS_VALID_ := $(if $(filter $F,$(VALID_FLAVORS)),1,0)
ifeq ($(FLAVOR_IS_VALID_),0)
$(error F=$F is not a valid flavor (options are: $(VALID_FLAVORS)))
endif

# Verbosity flag (empty show nice messages, non-empty use make messages)
# When used internally, $V expand to @ is nice messages should be printed, this
# way it's easy to add $V in front of commands that should be silenced when
# displaying the nice messages.
export MAKD_VERBOSE := $V
override V := $(if $V,,@)
# honour make -s flag
override V := $(if $(findstring s,$(MAKEFLAGS)),,$V)

# If $V is non-empty, colored output is used if $(COLOR) is non-empty too
COLOR ?= 1
COLOR := $(if $V,$(COLOR))
export MAKD_COLOR = $(COLOR)

# ANSI color used for the command if $(COLOR) is non-empty
# The color is composed with 2 numbers separated by ;
# The first is the style. 00 is normal, 01 is bold, 04 is underline, 05 blinks,
# 07 is reversed mode
# The second is the color: 30 dark gray/black, 31 red, 32 green, 33 yellow, 34
# blue, 35 magenta, 36 cyan and 37 white.
# If empty, no special color is used.
COLOR_CMD ?= 00;33

# ANSI color used for the argument if $(COLOR) is non-empty
# See COLOR_CMD comment for details.
COLOR_ARG ?=

# ANSI color used for the warnings if $(COLOR) is non-empty
# See COLOR_CMD comment for details.
COLOR_WARN ?= 00;36

# ANSI color used for errors if $(COLOR) is non-empty
# See COLOR_CMD comment for details.
COLOR_ERR ?= 00;31

# ANSI color used for commands output if $(COLOR) is non-empty
# See COLOR_CMD comment for details.
COLOR_OUT ?= $(COLOR_ERR)

# To compile the D2 version, you can use make DVER=2
# FIXME_IN_D2: This is only present as a transitional solution, it should be
# removed after the D2 migration is done
DVER ?= 1
export MAKD_DVER := $(DVER)

# Default D compiler (tries first with dmd1 and uses dmd if not present)
ifeq ($(DVER),1)
export DC ?= dmd1
else
export DC ?= dmd
endif

# Default rdmd binary to use (same as with dmd)
RDMD ?= rdmd

# Garbage Collector to use
# (exported because other programs might use the variable)
D_GC ?= cdgc
export D_GC

# Default documentation generator tool to use (harbored-mod)
HMOD ?= hmod

# harbored-mod flags
HMODFLAGS ?= --project-name $(PROJECT_NAME) --project-version $(VERSION)

# Default fpm binary location
FPM ?= fpm

# Default dot binary location
DOT ?= dot

# Default package type
PKGTYPE ?= deb

# Default flags to pass to graph-deps (see --help for details)
GRAPH_DEPS_FLAGS ?= -c -C

# Default fpm flags. By default it builds Debian packages from files, a Debian
# changelog is provided, and a version and iteration (using the Debian version)
# (defined lazily so we can use target variables)
ifndef PKG_DEFAULTS
DISTRO_CODENAME="$(shell lsb_release -rs | grep rolling || lsb_release -cs)"
PKG_DEFAULTS = -D-f -D-sdir -D-t$(PKGTYPE) -D--deb-changelog="$O/changelog.Debian" \
		-D--version="$(PKGVERSION)" \
		-D--iteration="$(DISTRO_CODENAME)" \
		-d lsb_release="$(DISTRO_CODENAME)"
endif

# Before building, we remove any old Debian packages present in the packages
# directory and generate a Debian changelog file from git history
# (defined lazily so we can use target variables)
ifndef PKG_PREBUILD
PKG_PREBUILD = $V$(RM) $P/$*$(PKG_SUFFIX)_*.deb ; \
	$(MAKD_PATH)/git-deblog -i "$(PKGVERSION)" "$*$(PKG_SUFFIX)" \
		--since '1 year ago' > $O/changelog.Debian
endif

# Default compiler flags
#########################

ifeq ($(DVER),1)
DFLAGS ?= -di
endif

override DFLAGS += -g

ifeq ($F,devel)
override DFLAGS += -debug
endif

ifeq ($F,production)
override DFLAGS += -O -inline
endif


# Directories
##############

# Location of the submodules (libraries the project depends on)
SUBMODULES ?= $(shell git config -f $T/.gitmodules --name-only \
			  --get-regexp '^submodule\.[^\.]+.*\.path$$' | \
			  xargs -rn1 git config -f $T/.gitmodules --path --get)

# Name of the build directory (to use when excluding some paths)
BUILD_DIR_NAME ?= build

# Directories to exclude from the build directory tree replication
BUILD_DIR_EXCLUDE ?= $(BUILD_DIR_NAME) $(SUBMODULES) .git

# Base directory where to put variants (Variants Directory)
VD ?= $T/$(BUILD_DIR_NAME)

# Generated files top directory
G ?= $(VD)/$F

# Directory for temporary files, like objects, dependency files and other
# generated intermediary files
O ?= $G/tmp
export MAKD_TMPDIR := $O

# Directory for generated source files (will be included with -I)
GS ?= $G/include

# Generated packages directory
P ?= $G/pkg

# Binaries directory
B ?= $G/bin
export MAKD_BINDIR := $B

# Documentation directory
D ?= $(VD)/doc

# Directory of the current Build.mak (this might not be the same as $(CURDIR)
# This variable is "lazy" because $S changes all the time, so it should be
# evaluated in the context where $C is used, not here.
C = $T$(if $S,/$S)

# Version module generation
# A module with detailed version information will be generated in
# $(VERSION_FILE) unless $(VERSION_FILE) is empty. This file is generated using
# the helper script mkversion.sh and the module template Version.d.tpl.
VERSION_FILE := $(GS)/Version.d

# Generate a version description for the output binary. This calls `mkversion.sh`
# script which will generate a version string.
# XXX: Please note shell function doesn't inherit variables exported in
#      Makefile, so explicit passing of `DC` is performed (see
#      https://bugs.debian.org/184864 for an extended explanation)
VERSION := $(shell DC="$(DC)" $(MAKD_PATH)/mkversion.sh -p)

# Generate a version description for the package
# This translates between `git describe`-style version and Debian version.
# First the `v` prefix and hash prefix `g` are removed and the `-` separator is
# translated to `~` (`-` has a special meaning in Debian, used for the
# distro-specific version). Then if the version starts with a letter, prepends
# a 0 to make it a valid Debian version string. Then, if the repo is dirty,
# the -dirty suffix is moved closer to the real version number, and finally the
# `-` in the dirty separator is also replaced with `~`. This is done for
# improved Debian version comparison.
# Example: v1.2.1-4-gea7105b-dirty -> 1.2.1+4~dirty.20160202160552~ea7105b
PKGVERSION := $(shell echo $(VERSION) | \
                sed 's/^v\(.*\)/\1/' | \
                sed 's/^\(.*\)-\([0-9]\+\)-g\([0-9a-f]\+\)/\1+\2~\3/' | \
                sed 's/^\([^0-9]\)/0\1/' | \
                sed 's/\(~[0-9a-f]\+\)-dirty$$/-dirty\1/' | \
                sed 's/-dirty/~dirty.'`date +%Y%m%d%H%M%S`'/')

# The files specified in this variable will be excluded from the generated
# unit tests targets and from the integration test main files.
# By default all files called main.d in $C/$(SRC)/ are excluded too, it's assumed
# they'll have a main() function in them.
# Paths must be absolute (specify them with the $C/ prefix).
# The contents of this variable will be passed to the Make function
# $(filter-out), meaning you can specify multple patterns separated by
# whitespaces and each pattern can have one '%' that's used as a wildcard.
# For more information refer to the documentation:
# http://www.gnu.org/software/make/manual/make.html#Text-Functions
TEST_FILTER_OUT := $C/$(SRC)/%/main.d


# Functions
############

# Compare two strings, if they are the same, returns the string, if not,
# returns empty.
eq = $(if $(subst $1,,$2),,$1)

# Find files and get the their file names relative to another directory.
# $1 is the files suffix (".h" or ".cpp" for example).
# $2 is a directory rewrite, the matched files will be rewriten to
#    be in the directory specified in this argument (it defaults to $3 if
#    omitted).
# $3 is where to search for the files ($C if omitted).
# $4 is a `filter-out` pattern applied over the original file list (previous to
#    the rewrite). It can be empty, which has no effect (nothing is filtered).
find_files = $(patsubst $(if $3,$3,$C)/%$1,$(if $2,$2,$(if $3,$3,$C))/%$1, \
		$(filter-out $4,$(shell find $(if $3,$3,$C) -name '*$1')))

# Abbreviate a file name. Cut the leading part of a file if it match to the $T
# directory, so it can be displayed as if it were a relative directory. Take
# just one argument, the file name.
abbr_helper = $(subst $T,.,$(patsubst $T/%,%,$1))
abbr = $(if $(call eq,$(call abbr_helper,$1),$1),$1,$(addprefix \
		$(shell echo $R | sed 's|/\?\([^/]\+\)/\?|../|g'),\
		$(call abbr_helper,$1)))

# Helper functions for vexec
vexec_pc = $(if $1,\033[$1m%s\033[00m,%s)
vexec_p = $(if $(COLOR), \
	'   $(call vexec_pc,$(COLOR_CMD)) $(call vexec_pc,$(COLOR_ARG))\n$(if \
			$(COLOR_OUT),\033[$(COLOR_OUT)m)', \
	'   %s %s\n')
# Execute a command printing a nice message if $V is @.
# $1 is mandatory and it's the command to execute.
# $2 is the target name (defaults to $@).
# $3 is the command name (defaults to the first word of $1).
vexec = $(if $V,printf $(vexec_p) \
		'$(call abbr,$(if $3,$(strip $3),$(firstword $1)))' \
		'$(call abbr,$(if $2,$(strip $2),$@))' ; )$1 \
		$(if $(COLOR),$(if $(COLOR_OUT), ; r=$$? ; \
				printf '\033[00m' ; exit $$r))

# Same as vexec but it silence the echo command (prepending a @ if $V).
exec = $V$(call vexec,$1,$2,$3)

# Concatenate variables together.  The first argument is a list of variables
# names to concatenate.  The second argument is an optional prefix for the
# variables and the third is the string to use as separator (" ~" if omitted).
# For example:
# X_A := a
# X_B := b
# $(call varcat,A B,X_, --)
# Will produce something like "a -- b --"
varcat = $(foreach v,$1,$($2$v)$(if $3,$3, ~))

# Replace variables with specified values in a template file.  The first
# argument is a list of make variables names which will be replaced in the
# target file.  The strings @VARNAME@ in the template file will be replaced
# with the value of the make $(VARNAME) variable and the result will be stored
# in the target file.  The second (optional) argument is a prefix to add to the
# make variables names, so if the prefix is PREFIX_ and @VARNAME@ is found in
# the template file, it will be replaced by the value of the make variable
# $(PREFIX_VARNAME).  The third and fourth arguments are the source file and
# the destination file (both optional, $< and $@ are used if omitted). The
# fifth (optional) argument are options to pass to the substitute sed command
# (for example, use "g" if you want to do multiple substitutions per line).
replace = $(call exec,sed '$(foreach v,$1,s|@$v@|$($2$v)|$5;)' $(if $3,$3,$<) \
		> $(if $4,$4,$@))

# Create a file with flags used to trigger rebuilding when they change. The
# first argument is the name of the file where to store the flags, the second
# are the flags and the third argument is a text to be displayed if the flags
# have changed (optional).  This should be used as a rule action or something
# where a shell script is expected.
gen_rebuild_flags = $(shell if test x"$2" != x"`cat $1 2>/dev/null`"; then \
		$(if $3,test -f $1 && echo "$(if $(COLOR),$(if $(COLOR_WARN),\
			\033[$(COLOR_WARN)m$3\033[00m,$3),$3);";) \
		echo "$2" > $1 ; fi)

# Include sub-directory's Build.mak.  The only argument is a list of
# subdirectories for which Build.mak should be included.  The $S directory is
# set properly before including each sub-directory's Build.mak and restored
# afterwards.
define build_subdir_code
_parent__$d__dir_ := $$S
S := $$(if $$(_parent__$d__dir_),$$(_parent__$d__dir_)/$d,$d)
include $$T/$$S/Build.mak
S := $$(_parent__$d__dir_)
endef
include_subdirs = $(foreach d,$1,$(eval $(build_subdir_code)))

# Check if a certain debian package exists and if we have an appropriate
# version.
#
# $1 is the name of the package (required)
# $2 is the version string to check against (required)
# $3 is the compare operator (optional: >= by default, but it can be any of
#    <,<=,=,>=,>)
#
# You can use this as the first command to run for a target action, for
# example:
#
# myprogram: some-source.d
# 	$(call check_deb,dstep,0.0.1)
# 	rdmd --build --whatever.
#
check_deb = $Vi=`apt-cache policy $1 | grep Installed | cut -b14-`; \
	op="$(if $3,$3,>=)"; \
	test "$$i" = "(none)" -o -z "$$i" && { \
		printf "%bUnsatisfied dependency:%b %s\npackage '$1' is not installed (version $$op $2 is required)\n" \
			$(if $(COLOR),'\033[$(COLOR_ERR)m' '\033[00m', '' '') \
			>&2 ; exit 1; }; \
	dpkg --compare-versions "$$i" "$$op" "$2" || { \
		printf "%bUnsatisfied dependency:%b package '$1' version $$op $2 is required but $$i is installed\n" \
			$(if $(COLOR),'\033[$(COLOR_ERR)m' '\033[00m', '' '') \
			>&2 ; exit 1; };

# Builds a D target, running pre and post build scripts
# This function takes 3 optional arguments:
# 1: arguments to be passed to $(BUILD.d) (usually rdmd)
# 2: arguments to be passed to the $(PRE_BUILD_D) script
# 3: arguments to be passed to the $(POST_BUILD_D) script
define build_d
	$(PRE_BUILD_D) $2
	$(call exec,$(BUILD.d) --build-only $1 $(LOADLIBES) $(LDLIBS) -of$@ \
		$(firstword $(filter %.d,$^)))
	$(POST_BUILD_D) $3
endef

# Overridden and default flags
###############################

# Default rdmd flags
RDMDFLAGS ?= --force --compiler=$(DC)

# Default dmd flags
DIMPORTPATHS := -I$(GS) -I./$(SRC) $(foreach dep,$(SUBMODULES), -I./$(dep)/$(SRC))
override DFLAGS += $(DIMPORTPATHS)

# Include the user's makefile, Build.mak
#########################################

# We do it before declaring the rules so some variables like TEST_FILTER_OUT
# are used as prerequisites, so we need to define them before the rules are
# declared.
-include $T/Build.mak


# Version.d file generation
############################

ifneq ($(VERSION_FILE),)
# Updates the git version information
PRE_BUILD_D = $V$(MAKD_PATH)/mkversion.sh -o $(VERSION_FILE) \
		-m $(subst /,.,$(patsubst $(GS)/%.d,%,$(VERSION_FILE))) \
		$(MAKD_PATH)/Version.d.tpl $(SUBMODULES)
# Removes the Vesion.d file from the generated dependencies (so files don't get
# rebuilt just because the version file changed)
POST_BUILD_D = $Vsed -i '\|^ *$(VERSION_FILE).*$$|d' $(BUILD.d.depfile)
endif

# Default rules
################

# By default we build the `all` target (it can be overriden at the end of the
# user's Makefile)
.DEFAULT_GOAL := all

# This is not a rule, but is defined to match the LINK.* variables predefined
# in Make and have a more Make-ish look & feel.
BUILD.d.depfile = $O/$*.mak
BUILD.d = $(RDMD) $(RDMDFLAGS) --makedepfile=$(BUILD.d.depfile) $(DFLAGS) \
		$($@.EXTRA_FLAGS) $(addprefix -L,$(LDFLAGS)) $(TARGET_ARCH)

# Link binary programs
$B/%: $G/build-d-flags
	$(call build_d)

# Clean the whole build directory, uses $(clean) to remove extra files
.PHONY: clean
clean:
	$(call exec,$(RM) -r $(VD) $(clean),$(VD) $(clean))

# Phony target to build all packages
.PHONY: pkg
pkg: $(patsubst $(PKG)/%.pkg,$O/pkg-%.stamp,$(wildcard $(PKG)/*.pkg))

# Target to build a package based on the fpm definition (old packages are
# removed to avoid infinite pollution of the build directory, as every package
# is a different file)
$O/pkg-%.stamp: $(PKG)/%.pkg
	$(PKG_PREBUILD)
	$(call exec,PYTHONDONTWRITEBYTECODE=1 $(MAKD_PATH)/mkpkg \
		$(if $V,,-vv) -D-p"$P" -F "$(FPM)" \
		$(PKG_DEFAULTS) \
		-d suffix="$(PKG_SUFFIX)" -d version="$(PKGVERSION)" \
		-d builddir="$G" -d bindir="$B" -d name="$*$(PKG_SUFFIX)" \
		$<,$<,mkpkg)
	$Vtouch $@

# Unit tests rules
###################

# These are divided in 2 types: fast and slow.
# Unittests are considered fast unless stated otherwise, and the way to say
# a test is slow is by putting it in a file with the suffx _slowtest.d.
# Normally that should be appended to the file of the module that's being
# tested.
# All modules to be passed to the unit tester (fast or slow) are filtered
# through the $(TEST_FILTER_OUT) variable contents (using the Make function
# $(filter-out)).
# The target fastunittest build only the fast unit tests, the target
# allunittest builds both fast and slow unit tests, and the target unittest is
# an alias for allunittest.
.PHONY: fastunittest allunittest unittest
fastunittest: $O/fastunittests.stamp
allunittest: $O/allunittests.stamp
unittest: allunittest

# Add fastunittest to fasttest and unittest to test general targets
fasttest := fastunittest $(fasttest)
test := unittest $(test)

# Files to be tested in unittests, the user could potentially add more
UNITTEST_FILES += $(call find_files,.d,,$C/$(SRC),$(TEST_FILTER_OUT))

# Files to test when using fast or all unit tests
$O/fastunittests.d: $(filter-out %_slowtest.d,$(UNITTEST_FILES))
$O/allunittests.d: $(UNITTEST_FILES)

# Test runner module. Uses ocean if available
TEST_RUNNER_MODULE ?= $(shell \
	for sub in ${SUBMODULES}; do \
		if test "$$(basename $$sub)" = "ocean"; then \
			echo ocean.core.UnitTestRunner; \
			break; \
		fi; \
	done)

# if no UnitTestRunner module is found and it was not overriden
# from command line or Config.mak, use default D test runner
# as a fallback
ifeq ($(TEST_RUNNER_MODULE),)
TEST_RUNNER_STRING ?= void main() {}
else
TEST_RUNNER_STRING ?= import $(TEST_RUNNER_MODULE);
endif

# General rule to build the unittest program using the UnitTestRunner
$O/%unittests.d: $G/build-d-flags
	$(call exec,printf 'module $(patsubst $O/%.d,%,$@);\n\
		$(TEST_RUNNER_STRING)\n\
		\n$(foreach f,$(filter %.d,$^),\
		import $(subst /,.,$(patsubst $C/$(SRC)/%.d,%,$f));\n)' > \
			$@,,gen)

# Configure dependencies files specific to each special unittests target
$O/fastunittests: BUILD.d.depfile := $O/fastunittests.mak
$O/allunittests: BUILD.d.depfile := $O/allunittests.mak

# General rule to build the generated unittest program
$O/%unittests: $O/%unittests.d $G/build-d-flags
	$(call build_d,-unittest -debug=UnitTest -version=UnitTest)

# General rule to run the unit tests binaries
$O/%unittests.stamp: $O/%unittests
	$(call exec,$< $(if $(findstring k,$(MAKEFLAGS)),-k) $(if $V,,-v -s) \
		$(foreach p,$(patsubst %.d,%,$(notdir $(shell \
			find $T/$(SRC) -maxdepth 1 -mindepth 1 \
				-name '*.d' -type f \
			))),-p $p) \
		$(foreach p,$(notdir $(shell \
			find $T/$(SRC) -maxdepth 1 -mindepth 1 -type d \
			)),-p $p.) $(UTFLAGS),$<,run)
	$Vtouch $@

# Integration tests rules
##########################

# Integration tests are assumed to be standalone programs, so we just search
# for files test/%/main.d and assume they are the entry point of the program
# (and each subdirectory in test/ is a separate program).
# The sources list is filtered through the $(TEST_FILTER_OUT) variable contents
# (using the Make function $(filter-out)), so you can exclude an integration
# test by adding the location of the main.d (as an absolute path using $C) by
# adding it to this variable.
# The target integrationtest builds and runs all the integration tests.
.PHONY: integrationtest
integrationtest: $(patsubst $T/test/%/main.d,$O/test-%.stamp,\
		$(filter-out $(TEST_FILTER_OUT),$(wildcard $T/test/*/main.d)))

# Add integrationtest to the test general target
test += integrationtest

# General rule to build integration tests programs, this is the same as
# building any other binary but including unittests too.
$O/test-%: BUILD.d.depfile = $O/test-$*.mak
$O/test-%: $T/test/%/main.d $G/build-d-flags
	$(call build_d,-unittest -debug=UnitTest -version=UnitTest)

# General rule to Run the test suite binaries
$O/test-%.stamp: $O/test-%
	$(call exec,$< $(ITFLAGS),$<,run)
	$Vtouch $@

# Documentation rules
######################

# General rule to run the harbored-mod generator
$O/doc.stamp: $(shell find $(SRC) -type f \( -name '*.d' -o -name '*.di' \))
	$(call exec,$(HMOD) -o $D $(HMODFLAGS) $(SRC) >/dev/null,doc)
	$Vtouch $@

doc += $O/doc.stamp

# Graph dependencies rule
##########################

.PHONY: graph-deps
graph-deps: $O/deps.svg

$O/%.svg: $O/%.dot
	$(call exec,$(DOT) -T svg $< -o $@)

$O/deps.dot: $O/depsfile
	$(call exec,$(MAKD_PATH)/graph-deps $(GRAPH_DEPS_FLAGS) $< $@,$@,graph-deps)

$O/depsfile: $O/allunittests.d
	$(call exec,$(DC) $(DFLAGS) -o- -deps=$@ $<)

# Create build directory structure
###################################

# Create $O, $B and $D directories and replicate the directory structure of the
# project into $O. Create one symbolic link "last" to the current build
# directory.
setup_build_dir__ := $(shell \
	mkdir -p $O $B $D $(GS) $P $(addprefix $O,$(patsubst $T%,%,\
		$(shell find $T -type d $(foreach d,$(BUILD_DIR_EXCLUDE), \
			-not -path '$T/$d' -not -path '$T/$d/*' \
			-not -path '$T/*/$d' -not -path '$T/*/$d/*')))); \
	rm -f $(VD)/last && ln -s $F $(VD)/last )


# Automatic rebuilding when flags or commands changes
######################################################

# Re-build binaries and libraries if one of this variables changes
BUILD.d.FLAGS := $(call varcat,RDMD RDMDFLAGS DFLAGS LDFLAGS TARGET_ARCH prefix)

setup_flag_files__ := $(setup_flag_files__)$(call gen_rebuild_flags, \
	$G/build-d-flags, $(BUILD.d.FLAGS),D compiler)

# Print any generated message (if verbose)
$(if $V,$(if $(setup_flag_files__), \
	$(info !! Flags or commands changed:$(setup_flag_files__) re-building \
			affected files...)))


# Targets using special variables
##################################
# These targets need to be after processing the Build.mak so all the special
# variables get populated.

# Phony rule to make all the targets (sub-makefiles can append targets to build
# to the $(all) variable).
.PHONY: all
all: $(all)

# Phony rule to build all documentation targets (sub-makefiles can append
# documentation to build to the $(doc) variable).
.PHONY: doc
doc: $(doc)

# Phony rule to build and run all test (sub-makefiles can append targets to
# build and run tests to the $(test) variable).
.PHONY: test
test: $(test)

# Phony rule to build and run all fast tests (sub-makefiles can append targets
# to build and run tests to the $(fasttest) variable).
.PHONY: fasttest
fasttest: $(fasttest)


# Temporary rule to convert code from D1 to D2
###############################################


.PHONY: d2conv
d2conv: $O/d2conv.stamp

$O/d2conv.stamp: $C
	$Vfind $C -type f -regex '^.+\.d$$' > $@
ifeq "$(shell d1to2fix --help 2>/dev/null | grep -- --input)" ""
	$(call exec, d1to2fix --fatal `cat $@`)
else
	$(call exec, d1to2fix $(DIMPORTPATHS) --fatal --input=$@)
endif

# Automatic dependency handling
################################

# These files are created during compilation.
-include $(shell test -d $O && find $O -name '*.mak')

endif
