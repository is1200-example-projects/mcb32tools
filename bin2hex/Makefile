SRCDIR		= $(shell pwd)
BUILDDIR	= ../build/bin2hex

INCS		+= -I$(SRCDIR)/../build/binutils/bfd
INCS		+= -I$(SRCDIR)/../downloads/$(BUILD_BINUTILS)/include
INCS		+= -I$(SRCDIR)/../build/binutils/binutils
INCS		+= -I$(SRCDIR)/../downloads/$(BUILD_BINUTILS)/binutils
LIBS		+= $(SRCDIR)/../build/binutils/bfd/libbfd.la
LIBS		+= $(SRCDIR)/../build/binutils/libiberty/libiberty.a
LIBS		+= $(SRCDIR)/../build/binutils/binutils/bucomm.o
LIBS		+= $(SRCDIR)/../build/binutils/binutils/filemode.o

CFLAGS		+= -Wall $(INCS)

$(BUILDDIR)/$(TARGET)-bin2hex: $(BUILDDIR) $(BUILDDIR)/bin2hex.o
	libtool --mode=link gcc -o $@ $(BUILDDIR)/bin2hex.o $(LIBS)

install:
	install -m 755 -t "$(PREFIX)/bin" "$(BUILDDIR)/$(TARGET)-bin2hex"

install-strip:
	install -s -m 755 -t "$(PREFIX)/bin" "$(BUILDDIR)/$(TARGET)-bin2hex"

$(BUILDDIR):
	mkdir -p $@

$(BUILDDIR)/bin2hex.o: $(SRCDIR)/bin2hex.c
	$(CC) $(CFLAGS) -c -o $@ $<
