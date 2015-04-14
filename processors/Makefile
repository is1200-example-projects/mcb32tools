BUILDDIR	= ../build/lib/proc

SYMFILES	= $(wildcard *.syms)
OBJFILES	= $(addprefix $(BUILDDIR)/,$(SYMFILES:.syms=.o))

.PHONY: all install

all: $(OBJFILES)

install:
	echo nope
	
clean:
	$(RM) $(OBJFILES)

$(BUILDDIR):
	mkdir -p "$@"

$(BUILDDIR)/%.o: %.syms $(BUILDDIR)
	"$(PREFIX)/bin/$(TARGET)-ld" -o "$@" -r "--just-symbols=$<"
