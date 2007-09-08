CC =      /usr/local/arm-apple-darwin/bin/gcc \
		  -I./PurpleSupport/include/ \
		  -I./PurpleSupport/include/libxml2 \
		  -I./PurpleSupport/include/glib-2.0 \
		  -I./PurpleSupport/include/glib-2.0/glib \
		  -I./PurpleSupport/include/glib-2.0/gmodule \
		  -I/usr/local/arm-apple-darwin/include
LD = $(CC)
LDFLAGS = -Wl,-syslibroot,$(HEAVENLY) \
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
		  -lpurple \
		  -loscar \
		  -lqq \
		  -lgg \
		  -lzephyr \
		  -lirc \
		  -ljabber \
		  -lmsn \
		  -lglib-2.0 \
		  -lgmodule-2.0 \
		  -lxml2

#CFLAGS = -DDEBUG

all:	prep ApolloIM package

%.o:	%.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o:	%.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o:	%.cpp
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

prep:
		#Something should be done here to counteract the NSObject problems we keep having.
	
ApolloIM:	main.o ApolloIMApp.o StartView.o AccountsView.o AccountEditorView.o Acct.o  ApolloCore.o ApolloIM-Callbacks.o  BuddyView.o Buddy.o Conversation.o ConversationView.o ShellKeyboard.o Shimmer.o AboutView.o ApolloNotificationController.o SendBox.o AcctCell.o AcctTable.o PreferenceController.o BuddyInfoView.o PreferencesView.o ApolloIM-Connection.o
			$(LD) $(LDFLAGS) -o $@ $^	./PurpleSupport/lib/libintl.a ./PurpleSupport/lib/libiconv.a

clean:
	rm -f *.o ApolloIM

package:
	rm -rf Purple.app
	mkdir Purple.app
	cp ApolloIM ./Purple.app/
	cp Info.plist ./Purple.app/
	cp vibrator ./Purple.app/
	chmod 644 ./Purple.app/*
	chmod 755 ./Purple.app/ApolloIM
	chmod 755 ./Purple.app/vibrator
