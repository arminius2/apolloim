CC =      /usr/local/arm-apple-darwin/bin/gcc \
		  -I./PurpleSupport/include/ \
		  -I./PurpleSupport/include/libxml2 \
		  -I./PurpleSupport/include/glib-2.0 \
		  -I./PurpleSupport/include/glib-2.0/glib \
		  -I./PurpleSupport/include/glib-2.0/gmodule \
		  -I/usr/local/arm-apple-darwin/include
LD = $(CC)
LDFLAGS = -Wl,-syslibroot,/Developer/SDKs/iPhone/heavenly \
          -framework Message \
          -framework CoreFoundation \
          -framework Foundation \
          -framework UIKit \
          -framework LayerKit \
          -framework CoreGraphics \
          -framework CoreTelephony \
          -framework GraphicsServices \
          -framework CoreSurface \
          -framework Celestial \
          -framework CoreAudio \
          -L./PurpleSupport/lib \
      	  -lobjc \
      	  -lz \
		  -lpurple \
		  -loscar \
		  -lqq \
		  -lgg \
		  -lzephyr \
		  -lirc \
		  -ljabber \
		  -lglib-2.0 \
		  -lgmodule-2.0 \
		  -lxml2 \
		  -lssl \
		  -lmsn

#CFLAGS = -DDEBUG

all:	Apollo package

%.o:	%.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o:	%.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o:	%.cpp
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
	
Apollo:	main.o ApolloApp.o Preferences.o Buddy.o Event.o User.o LoginCell.o LoginView.o ProtocolManager.o \
	UserManager.o BuddyCell.o BuddyListView.o ViewController.o AccountEditView.o AccountTypeSelector.o Conversation.o \
	ConversationView.o SendBox.o ShellKeyboard.o ConvWrapper.o PurpleInterface.o ApolloCore.o ApolloNotificationController.o AddressBook.o sqlite3.o
			$(LD) $(LDFLAGS) -o $@ $^	./PurpleSupport/lib/libintl.a ./PurpleSupport/lib/libgnt.a ./PurpleSupport/lib/libiconv.a ./PurpleSupport/lib/libresolv.a 

clean:
	rm -f *.o Apollo

package:
	rm -rf Apollo.app
	mkdir -p Apollo.app/Plugins
	cp Apollo ./Apollo.app/
	cp ./Plugins/ssl-gnutls.so ./Apollo.app/Plugins/
	cp ./Plugins/ssl.so ./Apollo.app/Plugins/
	cp ./PurpleSupport/hosts ./Apollo.app/
	cp resources/*.plist ./Apollo.app/
	cp resources/vibrator ./Apollo.app/
	cp resources/images/* ./Apollo.app/
	cp resources/sounds/* ./Apollo.app/
	chmod 755 ./Apollo.app/Apollo
	chmod 755 ./Apollo.app/vibrator

