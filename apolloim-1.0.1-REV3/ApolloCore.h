/*
 Apollo: Libpurple based Objective-C IM Client
 By Alex C. Schaefer & Adam Bellmore

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
 
 Portions of this code are referenced from "Libpurple", courtesy of www.pidgin.im
 as well as AdiumX (www.adiumx.com).  This code is full GPLv2, and a GPLv2.txt 
 is contained in the source and program root for you to read.  If not, please
 refer to the above address to obtain your own copy.
 
 Any questions or comments should be posted at http://apolloim.googlecode.com
*/

#import <Foundation/Foundation.h>
//#import "ApolloNotificationController.h"
//Purple
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

#import "Buddy.h"
#import "ConvWrapper.h"
#include "CONST.h"
#include "common.h"
#include "User.h"

@interface ApolloCore : NSObject
{
	NSThread* mainLoopThread;
	int	connections;
	
	id _delegate;
		
	NSMutableDictionary* activeAccounts;
	NSMutableDictionary* activeConversations;
	NSMutableDictionary* pendingAccounts;
	
	int num;
	GList *iter;
	GList *names;
	const char *prpl;
	GMainLoop *loop;
}

+ (void)initialize;
+ (id)sharedInstance;

- (id)init;

- (void)registerConnection:(User *)theAccount;
- (void)destroyConnection :(User *)theAccount;  

- (void)connect:(User *)theAccount;
- (void)disconnect:(User *)theAccount;

- (void)away:(User*) theAccount;
- (void)back:(User*) theAccount;

- (void)threadedGlib;

- (void)connected:(PurpleAccount*)theAccount;
- (void)disconnected:(PurpleAccount*)theAccount;
- (void)connectionStatus:(int)statusLevel withMessage:(NSString*)message forAccount:(PurpleAccount*)account;
- (int)connectionCount;

- (void)sendIM:(NSString *)body toBuddyName:(NSString *)buddy fromAcct:(User *)account;
- (void)receivedMessage:(NSString *)message withBuddyName:(NSString*)buddy fromAcct:(PurpleAccount*)account;
- (void)errorBecauseOfMessageWith:(NSString*)buddyName fromAccount:(User *)account withError:(NSString*)error isCritical:(bool)maybe;

- (void)buddyUpdate:(Buddy*)buddy withCode:(int)code;
//- (void)buddyUpdate:(Buddy*)buddy withCode:(int)code fromAccount:(PurpleAccount*)account;  //experiment

- (PurpleConversation*)conversationWith:(NSString *)buddy fromAcct:(User *)account;
- (void)createdConversation:(ConvWrapper*)conv withBuddyName:(NSString*)buddy fromAcct:(PurpleAccount*)account;

- (User *) getApolloUser:(PurpleAccount *) pa;
- (PurpleAccount *) getPurpleAccount:(User *) user;

- (void) reset;
- (void) goTeamCancer;

- (void)dealloc;

@end
