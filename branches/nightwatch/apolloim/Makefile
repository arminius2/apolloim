CC = arm-apple-darwin-cc 
LD = $(CC)
LDFLAGS = -lobjc \
          -framework CoreFoundation \
          -framework Foundation \
          -framework UIKit \
          -framework LayerKit \
          -framework CoreGraphics \
          -framework GraphicsServices \
          -framework CoreSurface \
          -framework Celestial \
          -framework CoreAudio \
          -L./libfiretalk \
          -lfiretalk \
          -L/Developer/SDKs/iPhone/lib \
		  -larmfp

#CFLAGS = -DDEBUG

all:	ApolloIM package

ApolloIM:	main.o ApolloIMApp.o StartView.o AccountsView.o AccountEditorView.o Account.o  ApolloTOC.o ApolloIM-Callback.o  BuddyView.o Buddy.o Conversation.o ConvoBox.o ShellKeyboard.o Shimmer.o AboutView.o SendBox.o 
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

#pxl: 	
#Ê  	zip -r ApolloIM.pxl PxlPkg.plist ApolloIM.app

package:
	rm -rf ApolloIM.app
	mkdir ApolloIM.app
	cp ApolloIM ./ApolloIM.app/
	cp *.png ./ApolloIM.app/
	cp *.gif ./ApolloIM.app/
	cp Info.plist ./ApolloIM.app/
#	pxl
