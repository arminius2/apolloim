/*
 ApolloCore.m: Objective-C firetalk interface.
 By Alex C. Schaefer
 Modification of BoomBot's objc/firetalk wrapper

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

//Start of includes copied from nullclient.
#include <libpurple/internal.h>
#include <libpurple/account.h>
#include <libpurple/conversation.h>
#include <libpurple/core.h>
#include <libpurple/debug.h>
#include <libpurple/eventloop.h>
#include <libpurple/ft.h>
#include <libpurple/log.h>
#include <libpurple/notify.h>
#include <libpurple/prefs.h>
#include <libpurple/prpl.h>
#include <libpurple/pounce.h>
#include <libpurple/savedstatuses.h>
#include <libpurple/sound.h>
#include <libpurple/status.h>
#include <libpurple/util.h>
#include <libpurple/whiteboard.h>
#include <libpurple/defines.h>

#include <glib.h>
#include <string.h>
#include <unistd.h>


//End of includes copied from nullclient.

#import <Foundation/Foundation.h>
#import "ApolloNotificationController.h"
#import "Buddy.h"

#include "ApolloIM-Callbacks.h"

typedef enum {ApolloCORE_DISCONNECTED, ApolloCORE_CONNECTING, ApolloCORE_CONNECTED} ApolloCORE_ConnectionStatus;

@interface ApolloTOC : NSObject
{
	NSTimer* keepAlive;
	
    BOOL willSendMarkup;
//	BOOL status;
    ApolloCORE_ConnectionStatus connected;

	NSMutableArray *connectionHandles;

	Buddy *you;
	
    NSString *infoMessage;
	
	id _delegate;
//Purple
	int num;
	GList *iter;
	GList *names;
	const char *prpl;
	GMainLoop *loop;
	PurpleAccount *account;
	PurpleSavedStatus *status;
//I wish it was magenta that would make me happy
}

+ (void)initialize;
+ (id)sharedInstance;
+ (id)dump;

- (id)init;
- (void)dealloc;
- (void)setDelegate:(id)delegate;
- (NSString*)infoMessage;
- (void)setInfoMessage:(NSString*)newMessage;

- (BOOL)connectUsingUsername:(NSString*)username password:(NSString*)password;
//- (void)listBuddies;
- (BOOL)connected;
- (void)disconnect;

- (void)sendIM:(NSString*)body toUser:(NSString*)user;
- (void)buddyUpdate:(Buddy*)buddy withCode:(int)code;

- (NSString*) userName;
- (Buddy*)you;
- (void)getInfo:(Buddy*)aBuddy;


@end
