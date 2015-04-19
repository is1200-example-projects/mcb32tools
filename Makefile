export TARGET	= mipsel-pic32-elf
export PREFIX	= /opt/pic32-toolchain

DISTRIB_LINUX_NAME	= $(PWD)/pic32-toolchain.tar.bz2
DISTRIB_WINDOWS_NAME	= $(PWD)/pic32-toolchain.zip
DISTRIB_MACOS_NAME	= $(PWD)/pic32-toolchain.dmg

# Build GCC against static GMP, MPFR, MPC
STATIC			= true

# Versions
export BUILD_AVRDUDE	= avrdude-5.11
export BUILD_BINUTILS	= binutils-2.25
export BUILD_GCC	= gcc-4.9.2
export BUILD_BIN2HEX	= bin2hex
export BUILD_MPC	= mpc-1.0.3
export BUILD_MPFR	= mpfr-3.1.2
export BUILD_GMP	= gmp-6.0.0
export BUILD_MAKE	= make-4.1

# These are the URLs we should download from
URLS 		= \
	http://download.savannah.gnu.org/releases/avrdude/$(BUILD_AVRDUDE).tar.gz \
	http://ftp.gnu.org/gnu/binutils/$(BUILD_BINUTILS).tar.bz2 \
	http://ftp.gnu.org/gnu/gcc/$(BUILD_GCC)/$(BUILD_GCC).tar.bz2 \
	http://ftp.gnu.org/gnu/mpc/$(BUILD_MPC).tar.gz \
	http://ftp.gnu.org/gnu/gmp/$(BUILD_GMP)a.tar.bz2 \
	http://ftp.gnu.org/gnu/mpfr/$(BUILD_MPFR).tar.bz2 \
	http://ftp.gnu.org/gnu/make/$(BUILD_MAKE).tar.bz2

# Packages that should be downloaded
DOWNLOADS	= \
	downloads/$(BUILD_AVRDUDE) \
	downloads/$(BUILD_BINUTILS) \
	downloads/$(BUILD_GCC) \
	downloads/$(BUILD_MPC) \
	downloads/$(BUILD_MPFR) \
	downloads/$(BUILD_GMP) \
	downloads/$(BUILD_MAKE)

# Tar flags for different archive formats
TARFORMATS = z.gz j.bz2 J.xz

# New config.guess and config.sub
CONFIG_GUESS_URL	= "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD"
CONFIG_SUB_URL		= "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD"

# Detemine what downloader to use
ifneq (,$(DOWNLOADER))
else ifneq (,$(shell wget -V))
	DOWNLOADER = wget -O -
else ifneq (,$(shell curl -V))
	DOWNLOADER = curl -L
else
	$(error No downloader found. Please install wget or curl and re-run)
endif


# Configure options
CONFIG_AVRDUDE	= --prefix="$(PREFIX)" --program-prefix="$(TARGET)-"

CONFIG_BINUTILS	= --target="$(TARGET)" --prefix="$(PREFIX)" --with-float=soft \
	--enable-soft-float --enable-static

CONFIG_GCC	= --target="$(TARGET)" --prefix="$(PREFIX)" \
	--enable-languages=c,c++ --with-newlib --with-gnu-as --with-gnu-ld \
	--without-headers --disable-libssp --with-float=soft \
	--with-arch=mips32r2 --disable-multilib

CONFIG_MPC	= --prefix="$(PREFIX)" --enable-shared=no \
	--with-gmp-include="$(PREFIX)/include" \
	--with-gmp-lib="$(PREFIX)/lib" \
	--with-mpfr-include="$(PREFIX)/include" \
	--with-mpfr-lib="$(PREFIX)/lib"

CONFIG_MPFR	= --prefix="$(PREFIX)" --enable-shared=no \
	--with-gmp-include="$(PREFIX)/include" \
	--with-gmp-lib="$(PREFIX)/lib"

CONFIG_GMP	= --prefix="$(PREFIX)" --enable-shared=no \
	--disable-assembly

CONFIG_MAKE	= --prefix="$(PREFIX)"

# Microsoft Windows and Mac OS X require static build
#ifeq ($(strip $(OS)), Windows_NT)
#STATIC		= true
#endif

GCCDEPS		=
ifeq ($(STATIC), true)
CONFIG_GCC	+= --with-mpc-include="$(PREFIX)/include" \
	--with-mpc-lib="$(PREFIX)/lib" \
	--with-gmp-include="$(PREFIX)/include" \
	--with-gmp-lib="$(PREFIX)/lib" \
	--with-mpfr-include="$(PREFIX)/include" \
	--with-mpfr-lib="$(PREFIX)/lib"

GCCDEPS		+= gmp mpfr mpc
endif

.PHONY: all stage2 gcc gcc-install binutils binutils-install avrdude \
	gmp mpc mpfr avrdude-install bin2hex bin2hex-install installdir \
	make make-install \
	processors runtime environment install clean

all: installdir
	+make stage2

stage2: binutils-install gcc-install avrdude-install bin2hex-install \
	install runtime-install
	@echo Done.


installdir:
	@touch "$(PREFIX)/.build" 2>/dev/null || ( \
		echo ""; \
		echo "************************************************************************"; \
		echo "$(PREFIX) directory must exist and be writeable by your user."; \
		echo "Please run the following commands before continuing:"; \
		echo "	sudo mkdir $(PREFIX)"; \
		echo "	sudo chown `id -un`:`id -gn` $(PREFIX)"; \
		echo "************************************************************************"; \
		echo ""; \
		echo ""; \
		exit 1)

build:
	mkdir -p "$@"

build/avrdude/config.status: downloads/$(BUILD_AVRDUDE) | build build/config.sub build/config.guess
	mkdir -p "$(@D)"
	cp -f build/config.sub downloads/$(BUILD_AVRDUDE)/config.sub
	cp -f build/config.guess downloads/$(BUILD_AVRDUDE)/config.guess
	(cd "$(@D)"; "../../downloads/$(BUILD_AVRDUDE)/configure" $(CONFIG_AVRDUDE))

avrdude: build/avrdude/config.status
	+make -C "build/$@"

avrdude-install: avrdude installdir
	+make -C "build/avrdude" install-strip
	@# Must run after avrdude is installed, not before
	install -m 644 avrdude.conf "$(PREFIX)/etc"

build/make/config.status: downloads/$(BUILD_MAKE) | build build/config.sub build/config.guess
	mkdir -p "$(@D)"
	cp -f build/config.sub downloads/$(BUILD_MAKEA)/config.sub
	cp -f build/config.guess downloads/$(BUILD_MAKE)/config.guess
	(cd "$(@D)"; "../../downloads/$(BUILD_MAKE)/configure" $(CONFIG_MAKE))

make: build/make/config.status
	+make -C "build/$@"

make-install: make installdir
	+make -C "build/make" install-strip

bin2hex: build binutils
	+make -C $@/

bin2hex-install: bin2hex installdir
	make -C bin2hex/ install-strip

build/binutils/config.status: downloads/$(BUILD_BINUTILS) | build build/config.sub build/config.guess
	mkdir -p "$(@D)"
	cp -f build/config.sub downloads/$(BUILD_BINUTILS)/config.sub
	cp -f build/config.guess downloads/$(BUILD_BINUTILS)/config.guess
	(cd "$(@D)"; "../../downloads/$(BUILD_BINUTILS)/configure" $(CONFIG_BINUTILS))

binutils: build/binutils/config.status
	+make -C "build/$@"

binutils-install: installdir binutils
	+make -C "build/binutils" install-strip

build/gmp/config.status: downloads/$(BUILD_GMP) | build build/config.sub build/config.guess
	mkdir -p "$(@D)"
	cp -f build/config.sub downloads/$(BUILD_GMP)/config.sub
	cp -f build/config.guess downloads/$(BUILD_GMP)/config.guess
	(cd "$(@D)"; "../../downloads/$(BUILD_GMP)/configure" $(CONFIG_GMP))

gmp: build/gmp/config.status
	+make -C "build/$@"
	+make -C "build/$@" install

build/mpfr/config.status: downloads/$(BUILD_MPFR) gmp | build build/config.sub build/config.guess
	mkdir -p "$(@D)"
	cp -f build/config.sub downloads/$(BUILD_MPFR)/config.sub
	cp -f build/config.guess downloads/$(BUILD_MPFR)/config.guess
	(cd "$(@D)"; "../../downloads/$(BUILD_MPFR)/configure" $(CONFIG_MPFR))

mpfr: build/mpfr/config.status
	+make -C "build/$@"
	+make -C "build/$@" install

build/mpc/config.status: downloads/$(BUILD_MPC) gmp mpfr | build build/config.sub build/config.guess
	mkdir -p "$(@D)"
	cp -f build/config.sub downloads/$(BUILD_MPC)/config.sub
	cp -f build/config.guess downloads/$(BUILD_MPC)/config.guess
	(cd "$(@D)"; "../../downloads/$(BUILD_MPC)/configure" $(CONFIG_MPC))

mpc: build/mpc/config.status
	+make -C "build/$@"
	+make -C "build/$@" install

build/gcc/config.status: downloads/$(BUILD_GCC) binutils-install $(GCCDEPS) | build build/config.sub build/config.guess
	mkdir -p "$(@D)"
	cp -f build/config.sub downloads/$(BUILD_GCC)/config.sub
	cp -f build/config.guess downloads/$(BUILD_GCC)/config.guess
	(cd "$(@D)"; "../../downloads/$(BUILD_GCC)/configure" $(CONFIG_GCC))

gcc: build/gcc/config.status
	+make -C "build/$@" all-gcc
	+make -C "build/$@" all-target-libgcc

gcc-install: gcc installdir
	+make -C "build/gcc" install-strip-gcc
	+make -C "build/gcc" install-target-libgcc

processors: binutils-install | build
	mkdir -p build/lib/proc
	mkdir -p build/include
	+make -C "processors"
	cp linkscripts/*.ld build/lib/proc/
	cp -r headers/* build/include/

runtime: binutils-install gcc-install processors | build
	+make -C "runtime/crt0"
	+make -C "runtime/crtprep"
	
runtime-install: installdir runtime
	+make -C "runtime/crt0" install
	+make -C "runtime/crtprep" install

environment: build
	sed "s/TOOLCHAIN_INSTALL_DIR=.*$$/TOOLCHAIN_INSTALL_DIR="$$(echo '$(PREFIX)' | sed -e 's/[\/&]/\\&/g')"/"\
		< environment > build/environment

download: $(DOWNLOADS) | build/config.sub build/config.guess

downloads:
	mkdir -p "$@"

downloads/%: | downloads
	$(eval URL = $(strip $(foreach v,$(URLS),$(if $(findstring $*,$v),$v))))
	$(eval TARFLAG = $(basename $(filter %$(suffix $(URL)),$(TARFORMATS))))
	@(cd downloads; test -d "$*" || $(DOWNLOADER) "$(URL)" | tar x$(TARFLAG))

build/config.guess: | build
	$(DOWNLOADER) $(CONFIG_GUESS_URL) > "$@"
	chmod 755 "$@"

build/config.sub: | build
	$(DOWNLOADER) $(CONFIG_SUB_URL) > "$@"
	chmod 755 "$@"

install: installdir processors environment
	install -d $(PREFIX)/include/proc
	install -d $(PREFIX)/include/sys
	install -d $(PREFIX)/lib/proc
	(cd build; find include/proc -type f -exec install -m 644 {} "$(PREFIX)/include/proc" \;)
	(cd build; find include/sys -type f -exec install -m 644 {} "$(PREFIX)/include/sys" \;)
	install -m 644 "build/include/cp0defs.h" "$(PREFIX)/include"
	(cd build; find lib -type f -exec install -m 644 {} "$(PREFIX)/lib/proc" \;)
	install -m 644 build/environment "$(PREFIX)/environment"
	sed 's/\$$PREFIX/$(shell echo '$(PREFIX)' | sed -e 's/[\/&]/\\&/g')/' \
		< os-specific/install-complete > build/install-complete
	install -m 755 build/install-complete "$(PREFIX)/install-complete"

distrib-linux:
	rm -f $(DISTRIB_LINUX_NAME)
	install -m 644 -t "$(PREFIX)/" doc/install-linux.txt
	cd `dirname $(PREFIX)` && tar -cjf $(DISTRIB_LINUX_NAME) `basename $(PREFIX)`

release:
	makeself-2.2.0/makeself.sh --bzip2 --target "$(PREFIX)" --lsm os-specific/pic32-toolchain.lsm \
		"$(PREFIX)" "pic32-toolchain-$(shell build/config.guess).run" "Pic32 Toolchain" ./install-complete

clean:
	$(RM) -R "build"
	@echo Done.
