CC = /usr/local/arm-apple-darwin/bin/gcc -I/Developer/SDKs/iPhone/include
LD = $(CC)
LDFLAGS = -Wl,-syslibroot,/Developer/SDKs/iPhone/heavenly \
          -L/Developer/SDKs/iPhone/lib \
          -L/Developer/SDKs/iPhone/heavenly/System/Library/Frameworks \
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
          -L./libfiretalk \
          -lfiretalk \
	  -lobjc \
          -larmfp

#CFLAGS = -DDEBUG

all:	ApolloIM package

ApolloIM:	main.o ApolloIMApp.o StartView.o AccountsView.o AccountEditorView.o Acct.o  ApolloTOC.o ApolloIM-Callback.o  BuddyView.o Buddy.o Conversation.o ConversationView.o ShellKeyboard.o Shimmer.o AboutView.o ApolloNotificationController.o SendBox.o AcctCell.o AcctTable.o PreferenceController.o BuddyInfoView.o PreferencesView.o
#		(cd libfiretalk && make)
		$(LD) $(LDFLAGS) -o $@ $^
		

%.o:	%.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o:	%.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o:	%.cpp
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

clean:
	rm -f *.o ApolloIM

package:
	rm -rf ApolloIM.app
	mkdir ApolloIM.app
	cp ApolloIM ./ApolloIM.app/
	cp *.png ./ApolloIM.app/
	cp *.gif ./ApolloIM.app/
	cp *.aiff ./ApolloIM.app/
	cp Info.plist ./ApolloIM.app/
	cp vibrator ./ApolloIM.app/
	chmod 644 ./ApolloIM.app/*
	chmod 755 ./ApolloIM.app/ApolloIM
	chmod 755 ./ApolloIM.app/vibrator
