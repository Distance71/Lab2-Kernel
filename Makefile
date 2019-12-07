CFLAGS := -m32 -g -std=c99 -Wall -Wextra -pedantic
CFLAGS += -O1 -fno-pic -fno-omit-frame-pointer -no-pie
ASFLAGS = -g -m32

ASMS := $(wildcard *.S)
SRCS := $(wildcard *.c)
PROG := $(SRCS:%.c=%) $(ASMS:%.S=%)

all: $(PROG)

clean:
	rm -f $(PROG) *.o core

.PHONY: clean all
