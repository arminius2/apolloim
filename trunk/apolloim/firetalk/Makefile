PREFIX=/usr/local
#INFLAGS=-DFIRETALK_USE_IPV6
CC=arm-apple-darwin-cc

OBJECTS = firetalk.o firedns.o firestring.o dummy.o irc.o toc1.o toc2.o toc.o aim.o safestring.o

all: static

compat: compat-shared

static:
	MYFLAGS="-O6 -fexpensive-optimizations -funroll-loops $(INFLAGS)" CC="arm-apple-darwin-cc" MYLIBS="-lresolv -lnsl -lm $(INLIBS)" $(MAKE) libfiretalk.a

shared:
	MYFLAGS="-O6 -fexpensive-optimizations -funroll-loops $(INFLAGS)" CC="arm-apple-darwin-cc" MYLIBS="-lresolv -lnsl -lm $(INLIBS)" $(MAKE) libfiretalk.so

compat-static:
	MYFLAGS="$(INFLAGS)" CC="arm-apple-darwin-cc" MYLIBS="-lresolv -lnsl -lm $(INLIBS)" $(MAKE) libfiretalk.a
	
compat-shared:
	MYFLAGS="$(INFLAGS)" CC="arm-apple-darwin-cc" MYLIBS="-lresolv -lnsl -lm $(INLIBS)" $(MAKE) libfiretalk.so

debug:
	$(MAKE) clean
	CFLAGS="" MYFLAGS="-DDEBUG -Wall -ansi -pedantic -g -fbounds-checking $(INFLAGS)" CC="bgcc" MYLIBS="-lresolv -lnsl -lm $(INLIBS)" $(MAKE) firetalk tester

gdb:
	$(MAKE) clean
	CFLAGS="" MYFLAGS="-DDEBUG -Wall -ansi -pedantic -g $(INFLAGS)" CC="gcc" MYLIBS="-lresolv -lnsl -lm $(INLIBS)" $(MAKE) firetalk tester

safestring.o: safestring.c safestring.h Makefile
	$(CC) $(CFLAGS) $(MYFLAGS) -c safestring.c

dummy.o: dummy.c dummy.h firetalk.h firetalk-int.h Makefile
	$(CC) $(CFLAGS) $(MYFLAGS) -c dummy.c

irc.o: irc.c irc.h firetalk.h firetalk-int.h Makefile
	$(CC) $(CFLAGS) $(MYFLAGS) -c irc.c

toc.o: toc.c toc.h firetalk.h firetalk-int.h Makefile
	$(CC) $(CFLAGS) $(MYFLAGS) -c toc.c

toc1.o: toc1.c toc1.h toc.h firetalk.h firetalk-int.h Makefile
	$(CC) $(CFLAGS) $(MYFLAGS) -c toc1.c

toc2.o: toc2.c toc2.h toc.h firetalk.h firetalk-int.h Makefile
	$(CC) $(CFLAGS) $(MYFLAGS) -c toc2.c

oscar.o: oscar.c oscar.h firetalk.h firetalk-int.h Makefile
	$(CC) $(CFLAGS) $(MYFLAGS) -c oscar.c

aim.o: aim.h aim.c Makefile
	$(CC) $(CFLAGS) $(MYFLAGS) -c aim.c

firetalk.o: firetalk.c toc.h irc.h oscar.h aim.h firetalk.h firetalk-int.h Makefile
	$(CC) $(CFLAGS) $(MYFLAGS) -c firetalk.c

libfiretalk.a: $(OBJECTS) Makefile
	rm -f libfiretalk.a
	ar cru libfiretalk.a $(OBJECTS) 
	ranlib libfiretalk.a

libfiretalk.so: $(OBJECTS) Makefile
	$(CC) -o libfiretalk.so -shared $(CFLAGS) $(MYFLAGS) $(LIBS) $(MYLIBS) $(OBJECTS)

gui.o: gui.c firetalk.h Makefile
	$(CC) $(CFLAGS) $(MYFLAGS) -c gui.c

tester.o: tester.c firetalk.h Makefile
	$(CC) $(CFLAGS) $(MYFLAGS) -c tester.c

firetalk: libfiretalk.a gui.o Makefile
	$(CC) $(CFLAGS) $(MYFLAGS) -lcurses $(LIBS) $(MYLIBS) -o firetalk gui.o libfiretalk.a

tester: libfiretalk.a tester.o Makefile
	$(CC) $(CFLAGS) $(MYFLAGS) $(LIBS) $(MYLIBS) -o tester tester.o safestring.o libfiretalk.a

clean:
	rm -f *.o *.a *.so firetalk tester

install: libfiretalk.so firetalk.h
	install -m 0755 -o root libfiretalk.so $(PREFIX)/lib
	install -m 0644 -o root firetalk.h $(PREFIX)/include

distclean: clean
