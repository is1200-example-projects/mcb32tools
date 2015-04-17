BUILDDIR	= ../../build/runtime

AR=$(PREFIX)/bin/$(TARGET)-ar
AS=$(PREFIX)/bin/$(TARGET)-as
CC=$(PREFIX)/bin/$(TARGET)-gcc
CXX=$(PREFIX)/bin/$(TARGET)-g++
CPP=$(PREFIX)/bin/(TARGET)-cpp

CFLAGS		= -I"$(PREFIX)/include" -ffreestanding -march=mips32r2 \
	-Wa,-march=mips32r2 -D__32MX320F128H__ -Wa,-msoft-float -Wall \
	-D__NEWLIB__ -msoft-float

CPPFLAGS	= -I"$(PREFIX)/include"
ASFLAGS = -march=mips32r2 -msoft-float

.PHONY: all install

all: $(BUILDDIR)/crt0.o

install:
	install -m 644 "$(BUILDDIR)/crt0.o" "$(wildcard $(PREFIX)/lib/gcc/$(TARGET)/*)/crt0.o"

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BUILDDIR)/%.o: %.S $(BUILDDIR)
	$(CC) -E $(CFLAGS) -c -o "$(@D)/$(F).gen.s" "$<"
	$(AS) $(ASFLAGS) -o "$@" "$(@D)/$(F).gen.s"
