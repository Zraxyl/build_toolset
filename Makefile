# Exports
PREFIX = $(shell pwd)
OUT = $(PREFIX)/src/out

# Flags for compiler / linker
CFALGS = -Wall -Werror
LDFLAGS = -L$(LD_LIBS)

# Compiler / linker
CC = /usr/bin/gcc
LD_LIBS = $(PREFIX)/libs
LD = /usr/bin/gcc

.PHONY: all

all: clean compile link symlink
	@echo "Pre-setup is now done!"
	@echo "cd to root of porject and run './drunk --help' for more information"

clean:
	@mkdir -p $(OUT) libs
	@rm -rf $(OUT)/* libs/*

compile:
	# libdrunk.so
	$(CC) -c $(CFLAGS) -fpic -o $(OUT)/libdrunk_msg.o src/libdrunk_msg.c
	$(CC) -c $(CFLAGS) -fpic -o $(OUT)/libdrunk.o src/libdrunk.c

link:
	# libdrunk.so
	$(LD) $(LDFLAGS) -shared -o libs/libdrunk.so $(OUT)/libdrunk_msg.o $(OUT)/libdrunk.o

	# Main executable
	$(CC) -Wall $(LDFLAGS) --debug -o libs/drunk src/main.c -Wl,-rpath=lib -ldrunk

symlink:
	@rm $(PREFIX)/../drunk
	@ln -sf $(PREFIX)/libs/drunk $(PREFIX)/drunk
	@ln -sf $(PREFIX)/drunk $(PREFIX)/../drunk
