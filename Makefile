# lsocket Makefile, works on Linux and Mac OS X, everywhere else roll your own.
#
# Gunnar Zötl <gz@tset.de>, 2013-2015.
# Released under the terms of the MIT license. See file LICENSE for details.

# swap the comments on the next 2 lines if you want the async resolver to be built and installed also
ALL=lsocket.so
#ALL=lsocket.so async_resolver.so

ifdef DEBUG
	DBG=-g
	OPT=
else
	DBG=
	OPT=-O2
endif

OS = $(shell uname -s)

CC=gcc
CFLAGS=-Wall -fPIC $(OPT) $(DBG)

# if this does not work, just set it to your version number
LUA_VERSION=lua$(shell lua -e "print((string.gsub(_VERSION, '^.+ ', '')))")
LUA_DIR = /usr
LUA_INCDIR=$(LUA_DIR)/include/$(LUA_VERSION)
INST_LIBDIR=$(LUA_DIR)/lib/lua/$(LUA_VERSION)

ifeq ($(OS),Darwin)
LIBFLAG=-bundle -undefined dynamic_lookup -all_load
else
LIBFLAG=-shared
endif

ifndef PTHRFLAG
PTHRFLAG=-pthread
endif

INCDIRS=-I$(LUA_INCDIR)
LDFLAGS=$(LIBFLAG) $(DBG)

all: $(ALL)

debug:; make DEBUG=1

install:	all
	mkdir -p $(INST_LIBDIR)
	cp $(ALL) $(INST_LIBDIR)

lsocket.so: lsocket.o
	$(CC) $(LDFLAGS) -o $@ $<

async_resolver.so: async_resolver.o gai_async.o
	$(CC) $(LDFLAGS) -o $@ $^ $(PTHRFLAG)

%.o: %.c
	$(CC) $(CFLAGS) $(INCDIRS) -c $< -o $@

async_resolver.o gai_async.o: gai_async.h

clean:
	find . -name "*~" -exec rm {} \;
	find . -name .DS_Store -exec rm {} \;
	find . -name ._* -exec rm {} \;
	rm -f *.o *.so core samples/testsocket

mingw: lsocket.dll

lsocket.dll : lsocket.c win_compat.c
	$(CC) -o $@ -Wall $(OPT) $(DBG) $(INCDIRS) $^ $(LDFLAGS) -lws2_32 -L/usr/local/bin -llua53
