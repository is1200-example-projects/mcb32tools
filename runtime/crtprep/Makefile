BUILDDIR	= ../../build/runtime
SRCFILES	= $(wildcard *.s)
OBJFILES	= $(addprefix $(BUILDDIR)/,$(SRCFILES:.s=.o))
ASFLAGS		= -msoft-float

.PHONY: all install

all: $(OBJFILES)

install:
	install "$(BUILDDIR)/crti.o" "$(wildcard $(PREFIX)/lib/gcc/$(TARGET)/*)/crti.o"
	install "$(BUILDDIR)/crtn.o" "$(wildcard $(PREFIX)/lib/gcc/$(TARGET)/*)/crtn.o"
	install "$(BUILDDIR)/crtbegin.o" "$(wildcard $(PREFIX)/lib/gcc/$(TARGET)/*)/crtbegin.o"
	install "$(BUILDDIR)/crtend.o" "$(wildcard $(PREFIX)/lib/gcc/$(TARGET)/*)/crtend.o"

$(BUILDDIR):
	mkdir -p $(BUILDDIR)


$(BUILDDIR)/%.o: %.s $(BUILDDIR)
	$(PREFIX)/bin/$(TARGET)-as $(ASFLAGS) -o $@ $<

