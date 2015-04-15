export TARGET	= mipsel-pic32-elf
export PREFIX	= /tmp/pic32-toolchain

# Build GCC against static GMP, MPFR, MPC
STATIC		= true

# Versions
export BUILD_AVRDUDE	= avrdude-5.11
export BUILD_BINUTILS	= binutils-2.25
export BUILD_GCC	= gcc-4.9.2
export BUILD_BIN2HEX	= bin2hex
export BUILD_MPC	= mpc-1.0.3
export BUILD_MPFR	= mpfr-3.1.2
export BUILD_GMP	= gmp-6.0.0

## These are the URLs we should download from
# http://ftp.gnu.org/gnu/binutils/$(BUILD_BINUTILS).tar.bz2
# http://ftp.gnu.org/gnu/gcc/$(BUILD_GCC)/$(BUILD_GCC).tar.bz2
# http://download.savannah.gnu.org/releases/avrdude/$(BUILD_AVRDUDE).tar.gz 
# http://ftp.gnu.org/gnu/mpc/$(BUILD_MPC).tar.gz
# http://ftp.gnu.org/gnu/gmp/$(BUILD_GMP).tar.bz2
# http://ftp.gnu.org/gnu/mpfr/$(BUILD_MPFR).tar.bz2


# Configure options
CONFIG_AVRDUDE	= --prefix="$(PREFIX)" --program-prefix="$(TARGET)-"

CONFIG_BINUTILS	= --target="$(TARGET)" --prefix="$(PREFIX)" --with-float=soft \
	--enable-soft-float --enable-static

CONFIG_GCC	= --target="$(TARGET)" --prefix="$(PREFIX)" \
	--enable-languages=c,c++ --with-newlib --with-gnu-as --with-gnu-ld \
	--without-headers --disable-libssp --with-float=soft \
	--with-arch=mips32r2 --disable-multilib

CONFIG_MPC	= --prefix="$(PREFIX)" --enable-shared=no \
	--with-gmp-include="../../download/$(BUILD_GMP)/src" \
	--with-gmp-lib="../../gmp/.libs" \
	--with-mpfr-include="../../download/$(BUILD_MPFR)/src" \
	--with-mpfr-lib="../../mpfr/src/.libs"

CONFIG_MPFR	= --prefix="$(PREFIX)" --enable-shared=no \
	--with-gmp-include="../../download/$(BUILD_GMP)/src" \
	--with-gmp-lib="../../gmp/.libs"

CONFIG_GMP	= --prefix="$(PREFIX)" --enable-shared=no

# Microsoft Windows and Mac OS X require static build
ifeq ($(strip $(OS)), Windows_NT)
STATIC		= true
endif

GCCDEPS		=
ifeq ($(STATIC), true)
CONFIG_GCC	+= --with-mpc-include="../../$(BUILD_MPC)/src" \
	--with-mpc-lib="../../mpc/src/.libs" \
	--with-gmp-include="../../download/$(BUILD_GMP)/src" \
	--with-gmp-lib="../../gmp/.libs" \
	--with-mpfr-include="../../download/$(BUILD_MPFR)/src" \
	--with-mpfr-lib="../../mpfr/src/.libs"

GCCDEPS		+= gmp mpfr mpc
endif

.PHONY: all stage2 gcc gcc-install binutils binutils-install avrdude \
	gmp mpc mpfr avrdude-install bin2hex bin2hex-install installdir \
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

avrdude: build
	mkdir -p "build/$@"
	(cd "build/$@"; "../../download/$(BUILD_AVRDUDE)/configure" $(CONFIG_AVRDUDE))
	+make -C "build/$@"

avrdude-install: avrdude installdir
	+make -C "build/avrdude" install

bin2hex: build binutils
	+make -C $@/

bin2hex-install: bin2hex installdir
	make -C bin2hex/ install

binutils: build
	mkdir -p "build/$@"
	(cd "build/$@"; "../../download/$(BUILD_BINUTILS)/configure" $(CONFIG_BINUTILS))
	+make -C "build/$@"

binutils-install: installdir binutils
	+make -C "build/binutils" install


gmp: build
	mkdir -p "build/$@"
	(cd "build/$@"; "../../download/$(BUILD_GMP)/configure" $(CONFIG_GMP))
	+make -C "build/$@"

mpfr: build gmp
	mkdir -p "build/$@"
	(cd "build/$@"; "../../download/$(BUILD_MPFR)/configure" $(CONFIG_MPFR))
	+make -C "build/$@"

mpc: build gmp mpfr
	mkdir -p "build/$@"
	(cd "build/$@"; "../../download/$(BUILD_MPC)/configure" $(CONFIG_MPC))
	+make -C "build/$@"

gcc: build binutils-install $(GCCDEPS)
	mkdir -p "build/$@"
	(cd "build/$@"; "../../download/$(BUILD_GCC)/configure" $(CONFIG_GCC))
	+make -C "build/$@" all-gcc
	+make -C "build/$@" all-target-libgcc

gcc-install: gcc installdir
	+make -C "build/gcc" install-gcc
	+make -C "build/gcc" install-target-libgcc

processors: build binutils-install
	mkdir -p build/lib/proc
	mkdir -p build/include
	+make -C "processors"
	cp linkscripts/*.ld build/lib/proc/
	cp -r headers/* build/include/

runtime: build binutils-install gcc-install processors
	+make -C "runtime/crt0"
	+make -C "runtime/crtprep"
	
runtime-install: installdir
	#runtime
	+make -C "runtime/crt0" install
	+make -C "runtime/crtprep" install

environment: build
	sed "s/TOOLCHAIN_INSTALL_DIR=.*$$/TOOLCHAIN_INSTALL_DIR="$$(echo '$(PREFIX)' | sed -e 's/[\/&]/\\&/g')"/"\
		< environment > build/environment

install: installdir processors environment
	(cd build; find include -type f -exec install -D -T -m 644 {} "$(PREFIX)/{}" \;)
	(cd build; find lib -type f -exec install -D -T -m 644 {} "$(PREFIX)/{}" \;)
	install -D -m 644 build/environment "$(PREFIX)"

clean:
	$(RM) -R "build"
	@echo Done.
