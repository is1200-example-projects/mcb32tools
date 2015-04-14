BUILDDIR	= ../../build/runtime
SRCFILES	= $(wildcard *.s)
OBJFILES	= $(addprefix $(BUILDDIR)/,$(SRCFILES:.s=.o))
ASFLAGS		= -msoft-float

.PHONY: all install

all: $(OBJFILES)

install:
	install -D -m 644 $(OBJFILES) $(PREFIX)/lib/gcc/$(TARGET)/*/

$(BUILDDIR):
	mkdir -p $(BUILDDIR)


$(BUILDDIR)/%.o: %.s $(BUILDDIR)
	$(PREFIX)/bin/$(TARGET)-as $(ASFLAGS) -o $@ $<

