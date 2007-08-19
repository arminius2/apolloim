PREFIX ?= /usr/local
INSTALL_USER ?= root
CFLAGS ?= -O6 -fexpensive-optimizations -funroll-loops
CC = arm-apple-darwin-cc
LD = /opt/local/arm-iphone/bin/ld
INCFLAGS = 
INLDFLAGS = 
INLIBS = 

all:  static
#all: dynlib

install: install-shared install-static install-headers install-man3

static: libfiredns.a

shared: libfiredns.so

dynlib: libfiredns.dynlib

debug: clean
	CC="bgcc" CFLAGS="-DDDEBUG -Wall -ansi -pedantic -g -fbounds-checking" $(MAKE) tester

gdb: clean
	CFLAGS="-DDEBUG -Wall -ansi -pedantic -g" $(MAKE) tester

libfiredns.a: firedns.o Makefile
	rm -f libfiredns.a
	ar cru libfiredns.a firedns.o
	ranlib libfiredns.a

libfiredns.dynlib: firedns.o Makefile
	$(CC) $(INCFLAGS) $(CFLAGS) $(INLDFLAGS) $(LDFLAGS) -o libfiredns.so -dynlib firedns.o $(INLIBS) $(LIBS)

libfiredns.so: firedns.o Makefile
	$(CC) $(INCFLAGS) $(CFLAGS) $(INLDFLAGS) $(LDFLAGS) -o libfiredns.so -shared firedns.o $(INLIBS) $(LIBS)

firedns.o: firedns.c firedns.h Makefile
	$(CC) $(INCFLAGS) $(CFLAGS) -c firedns.c

tester: tester.c libfiredns.a firedns.h
	$(CC) $(INCFLAGS) $(CFLAGS) $(INLDFLAGS) $(LDFLAGS) -o tester tester.c libfiredns.a $(INLIBS) $(LIBS)

clean:
	rm -f *.a *.o *.so tester

distclean: clean

install-headers: firedns.h
	install -d -m 0755 -o $(INSTALL_USER) $(PREFIX)/include
	install -m 0644 -o $(INSTALL_USER) firedns.h $(PREFIX)/include

install-shared: libfiredns.so
	install -d -m 0755 -o $(INSTALL_USER) $(PREFIX)/lib
	install -m 0755 -o $(INSTALL_USER) libfiredns.so $(PREFIX)/lib

install-static: libfiredns.a
	install -d -m 0755 -o $(INSTALL_USER) $(PREFIX)/lib
	install -m 0755 -o $(INSTALL_USER) libfiredns.a $(PREFIX)/lib

install-man3: man/*.3
	install -d -m 0755 -o $(INSTALL_USER) $(PREFIX)/man/man3
	install -m 0644 -o $(INSTALL_USER) man/*.3 $(PREFIX)/man/man3
