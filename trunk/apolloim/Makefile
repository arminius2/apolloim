CC =      /usr/local/arm-apple-darwin/bin/gcc \
          -I/Developer/SDKs/iPhone/include \
          -I./libpurple/glib \
		  -I./libpurple \
		  -I./libpurple/glib/gobject \
		  -I./libpurple/glib/gmodule
		  
LD = $(CC)
LDFLAGS = -Wl,-syslibroot,/Developer/SDKs/iPhone/heavenly \
          -L/Developer/SDKs/iPhone/lib \
          -L/Developer/SDKs/iPhone/heavenly/System/Library/Frameworks \
		  -L./libs \
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
      	  -lobjc \
		  -lpurple \
		  -loscar \
		  -lqq \
		  -lirc \
		  -ljabber \
		  -lmsn \
		  -lglib-2.0 \
		  -lresolv \
		  -lgmodule-2.0 \
		  -lxml2 \
          -larmfp		  
		  #		  -lintl \
		  #		  -liconv \

#CFLAGS = -DDEBUG

all:	ApolloIM package

ApolloIM:	main.o ApolloIMApp.o StartView.o AccountsView.o AccountEditorView.o Acct.o  ApolloCore.o ApolloIM-Callbacks.o  BuddyView.o Buddy.o Conversation.o ConversationView.o ShellKeyboard.o Shimmer.o AboutView.o ApolloNotificationController.o SendBox.o AcctCell.o AcctTable.o PreferenceController.o BuddyInfoView.o PreferencesView.o
		$(LD) $(LDFLAGS) -o $@ $^ ./libs/libiconv.a ./libs/libintl.a
		

%.o:	%.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o:	%.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o:	%.cpp
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

clean:
	rm -f *.o ApolloIM

package:
	rm -rf Purple.app
	mkdir Purple.app
	cp ApolloIM ./Purple.app/
#	cp *.png ./ApolloIM.app/
#	cp *.gif ./ApolloIM.app/
#	cp *.aiff ./ApolloIM.app/
	cp Info.plist ./Purple.app/
	cp vibrator ./Purple.app/
	chmod 644 ./Purple.app/*
	chmod 755 ./Purple.app/ApolloIM
	chmod 755 ./Purple.app/vibrator
