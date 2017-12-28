CC=gcc
CFLAGS=-g -Wall -Iinclude
LDFLAGS=

SRCDIR=src
OBJDIR=obj
BINDIR=bin

# Collect all sources in SRCDIR
SRCS=$(wildcard $(SRCDIR)/*.c)
# Translate to object names in OBJDIR
OBJS=$(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $(SRCS))

# Output binaries
BIN_ANALYZER=$(BINDIR)/analyzer
#BINS=$(patsubst $(OBJDIR)/%.o, $(BINDIR)/$(basename %.o), $(OBJS))


# Build all binaries
all: $(BIN_ANALYZER)

#$(BINS): $(BINDIR)/% : $(OBJDIR)/%.o
$(BIN_ANALYZER) : $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@

$(OBJS): $(OBJDIR)/%.o : $(SRCDIR)/%.c PRINT
	$(CC) $(CFLAGS) $(LDFLAGS) -c $< -o $@

.PHONY: PRINT
PRINT:
	@printf "Making objects\n"


.PHONY: clean

clean:
	rm -f $(OBJDIR)/*.o
	rm -f $(BINDIR)/*
