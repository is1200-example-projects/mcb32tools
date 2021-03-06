export TARGET	= mipsel-mcb32-elf
ifneq ($(shell uname -s),Darwin)
	# This defines install location for platforms that are *not* MacOS X
	export INSTALL_DIR	= /opt/mcb32tools
else
	# This defines where the application bundle will be built in MacOS X
	export INSTALL_DIR	= /Applications/mcb32tools.app
endif

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
export BUILD_LIBC	= mcb32libc-0.1

export MAKESELF	= makeself-2.2.0

# These are the URLs we should download from
URLS 		= \
	http://download.savannah.gnu.org/releases/avrdude/$(BUILD_AVRDUDE).tar.gz \
	http://ftp.gnu.org/gnu/binutils/$(BUILD_BINUTILS).tar.bz2 \
	http://ftp.gnu.org/gnu/gcc/$(BUILD_GCC)/$(BUILD_GCC).tar.bz2 \
	http://ftp.gnu.org/gnu/mpc/$(BUILD_MPC).tar.gz \
	http://ftp.gnu.org/gnu/gmp/$(BUILD_GMP)a.tar.bz2 \
	http://ftp.gnu.org/gnu/mpfr/$(BUILD_MPFR).tar.bz2 \
	http://ftp.gnu.org/gnu/make/$(BUILD_MAKE).tar.bz2 \
	https://github.com/is1200-example-projects/mcb32libc/releases/download/v0.1/$(BUILD_LIBC).tar.gz

# Packages that should be downloaded
DOWNLOADS	= \
	downloads/$(BUILD_AVRDUDE) \
	downloads/$(BUILD_BINUTILS) \
	downloads/$(BUILD_GCC) \
	downloads/$(BUILD_MPC) \
	downloads/$(BUILD_MPFR) \
	downloads/$(BUILD_GMP) \
	downloads/$(BUILD_MAKE) \
	downloads/$(BUILD_LIBC)

# Tar flags for different archive formats
TARFORMATS = z.gz j.bz2 J.xz

# New config.guess and config.sub
CONFIG_GUESS_URL	= "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD"
CONFIG_SUB_URL		= "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD"

# Detemine what downloader to use
ifneq (,$(DOWNLOADER))
else ifneq (,$(shell wget -V 2>/dev/null))
	DOWNLOADER = wget -O -
else ifneq (,$(shell curl -V 2>/dev/null))
	DOWNLOADER = curl -L
else
	$(error No downloader found. Please install wget or curl and re-run)
endif

## Must not be moved below first usage of $(PREFIX)!
ifeq ($(shell uname -s),Darwin)
	export PREFIX_DATA_ROOT = $(INSTALL_DIR)/Contents
	export PREFIX = $(INSTALL_DIR)/Contents/Resources/Toolchain
	EXTRA_INSTALL_TARGETS += install-mac-app make-install
else
	export PREFIX = $(INSTALL_DIR)
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
	make make-install install-mac-app mcb32libc mcb32libc-install \
	processors runtime environment install release clean

all: installdir
	+make stage2

stage2: binutils-install gcc-install avrdude-install bin2hex-install \
	install runtime-install mcb32libc-install $(EXTRA_INSTALL_TARGETS)
	@echo Done.


installdir:
	@-mkdir -p "$(PREFIX)" 2>/dev/null
	@touch "$(PREFIX)/.build" 2>/dev/null || ( \
		echo ""; \
		echo "************************************************************************"; \
		echo "$(INSTALL_DIR) directory must exist and be writeable by your user."; \
		echo "Please run the following commands before continuing:"; \
		echo "	sudo mkdir -p $(INSTALL_DIR)"; \
		echo "	sudo chown -R `id -un`:`id -gn` $(INSTALL_DIR)"; \
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
	cp -f build/config.sub downloads/$(BUILD_MAKE)/config.sub
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
	cp linkscripts/*.ld build/lib/proc/
	cp -r headers/* build/include/

runtime: binutils-install gcc-install processors | build
	+make -C "runtime/crt0"
	+make -C "runtime/crtprep"
	
runtime-install: installdir runtime
	+make -C "runtime/crt0" install
	+make -C "runtime/crtprep" install

mcb32libc: downloads/$(BUILD_LIBC) gcc-install environment | build
	mkdir -p build/mcb32libc
	
	+AR=$(PREFIX)/bin/$(TARGET)-ar \
		AS=$(PREFIX)/bin/$(TARGET)-as \
		CC=$(PREFIX)/bin/$(TARGET)-gcc \
		CXX=$(PREFIX)/bin/$(TARGET)-g++ \
		CPP=$(PREFIX)/bin/$(TARGET)-cpp \
		C_INCLUDE_PATH=$(PREFIX)/include \
		CFLAGS="-march=mips32r2 -msoft-float -Wa,-msoft-float -G 0" \
		ASFLAGS="-march=mips32r2 -msoft-float" \
		make -C "downloads/$(BUILD_LIBC)" BUILDDIR=../../build/mcb32libc STDIO=0

mcb32libc-install: installdir mcb32libc
	install -m 644 "build/mcb32libc/libc.a" "$(PREFIX)/lib/libc.a"
	install -m 644 "build/mcb32libc/libm.a" "$(PREFIX)/lib/libm.a"
	install -d "$(PREFIX)/include/sys"
	install -d "$(PREFIX)/include/klibc"
	install -d "$(PREFIX)/include/machine"
	(cd downloads/$(BUILD_LIBC); find include -maxdepth 1 -type f -exec install -m 644 {} "$(PREFIX)/include" \;)
	(cd downloads/$(BUILD_LIBC); find include/machine -maxdepth 1 -type f -exec install -m 644 {} "$(PREFIX)/include/machine" \;)
	(cd downloads/$(BUILD_LIBC); find include/sys -maxdepth 1 -type f -exec install -m 644 {} "$(PREFIX)/include/sys" \;)
	(cd downloads/$(BUILD_LIBC); find include/klibc -maxdepth 1 -type f -exec install -m 644 {} "$(PREFIX)/include/klibc" \;)

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
	install -d "$(PREFIX)/include/proc"
	install -d "$(PREFIX)/include/sys"
	install -d "$(PREFIX)/lib/proc"
	(cd build; find include/proc -type f -exec install -m 644 {} "$(PREFIX)/include/proc" \;)
	(cd build; find include/sys -type f -exec install -m 644 {} "$(PREFIX)/include/sys" \;)
	install -m 644 "build/include/cp0defs.h" "$(PREFIX)/include"
	install -m 644 "build/include/pic32mx.h" "$(PREFIX)/include"
	(cd build; find lib -type f -exec install -m 644 {} "$(PREFIX)/lib/proc" \;)
	install -m 644 build/environment "$(PREFIX)/environment"
	sed 's/\$$PREFIX/$(shell echo '$(PREFIX)' | sed -e 's/[\/&]/\\&/g')/' \
		< os-specific/install-complete > build/install-complete
	install -m 755 build/install-complete "$(PREFIX)/install-complete"

distrib-linux:
	rm -f $(DISTRIB_LINUX_NAME)
	install -m 644 -t "$(PREFIX)/" doc/install-linux.txt
	cd `dirname $(PREFIX)` && tar -cjf $(DISTRIB_LINUX_NAME) `basename $(PREFIX)`

ifneq ($(shell uname -s),Darwin)
release:
		## We're NOT building on OSX
		sed 's/^umask [0-7]*$$/umask 022/' < $(MAKESELF)/makeself-header.sh > build/makeself-header.sh
		$(MAKESELF)/makeself.sh --bzip2 --target "$(PREFIX)" --lsm os-specific/mcb32tools.lsm --header build/makeself-header.sh \
			"$(PREFIX)" "mcb32tools-$(shell build/config.guess).run" "MCB32 Tools" ./install-complete
else
release:
		## We are building on OSX
		rm -rf build/dmg
		mkdir -p build/dmg
		cp -r "$(INSTALL_DIR)" build/dmg/
		ln -s /Applications/ build/dmg/
		mkdir build/dmg/.meta
		cp os-specific/mac/background.png build/dmg/.meta/
		cp os-specific/mac/DS_Store build/dmg/.DS_Store
		hdiutil create "mcb32tools-$(shell build/config.guess).dmg" -format UDBZ -volname "MCB32Tools" -srcfolder build/dmg
endif

install-mac-app: installdir
	install -d "$(PREFIX_DATA_ROOT)/MacOS"
	install -m 644 "os-specific/mac/Info.plist" "$(PREFIX_DATA_ROOT)/"
	iconutil -o "$(PREFIX_DATA_ROOT)/Resources/toolchain.icns" -c icns "os-specific/mac/toolchain.iconset"
	@## TODO: Set the path correctly in launchterm
	sed 's/\$$PREFIX_DATA_ROOT/$(shell echo '$(PREFIX_DATA_ROOT)' | sed -e 's/[\/&]/\\&/g')/' \
		< os-specific/mac/mcb32tools-launch.c > build/mcb32tools-launch.c
	$(CC) -DMAC_APP_PATH=\"$(INSTALL_DIR)\" "build/mcb32tools-launch.c" -o "$(PREFIX_DATA_ROOT)/MacOS/mcb32tools-launch"
	install -d "$(PREFIX_DATA_ROOT)/Resources/en.lproj"

clean:
	$(RM) -R "build"
	@echo Done.
