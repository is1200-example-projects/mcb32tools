BUILDDIR	= ../../build/runtime
SRCFILES	= $(wildcard *.s)
OBJFILES	= $(addprefix $(BUILDDIR)/,$(SRCFILES:.s=.o))
ASFLAGS		= -msoft-float

.PHONY: all install

all: $(OBJFILES)

install:
	install -t "$(PREFIX)/lib/gcc/$(TARGET)/"*/ -m 644 $(OBJFILES)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)


$(BUILDDIR)/%.o: %.s $(BUILDDIR)
	$(PREFIX)/bin/$(TARGET)-as $(ASFLAGS) -o $@ $<

