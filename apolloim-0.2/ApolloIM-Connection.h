//
//  ApolloIM-Connection.h
//  ApolloIM
//
//  Created by Alex C. Schaefer on 9/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
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
//Purple

#include "Acct.h"

#define PURPLE_GLIB_READ_COND  (G_IO_IN | G_IO_HUP | G_IO_ERR)
#define PURPLE_GLIB_WRITE_COND (G_IO_OUT | G_IO_HUP | G_IO_ERR | G_IO_NVAL)

#import <Foundation/Foundation.h>
typedef enum {ApolloCORE_DISCONNECTED, ApolloCORE_CONNECTING, ApolloCORE_CONNECTED} ApolloCORE_ConnectionStatus;

@interface ApolloIM_Connection : NSObject 
{
    ApolloCORE_ConnectionStatus connected;
	
	Acct* thisAccount;
	id _delegate;
	
	int num;
	GList *iter;
	GList *names;
	const char *prpl;
	GMainLoop *loop;
	PurpleAccount *account;
	PurpleSavedStatus *status;
}

- (id)initWithAccount:(Acct*)newAccount withDelegate:(id)delegate;

- (void)registerCallbacks;

- (BOOL)connectUsingAccount:(Acct*)account;
- (void)disconnected:(NSString*)reason;
- (void)error:(int)code;
- (void)connectionSuccessful;

- (BOOL)connected;
- (void)disconnect;

- (void)sendIM:(NSString*)body     toBuddy:(Buddy*)buddy;
- (void)receivedMessage:(NSString*)message fromUser:(Buddy*)user;

- (void)buddyUpdate:(Buddy*)buddy withCode:(int)code;

- (NSString*) username;
- (Acct*)thisAccount;
- (void)getInfo:(Buddy*)aBuddy;

//Specifically Purple
void init_libpurple();
void signed_on(PurpleConnection *gc, gpointer null);
PurpleEventLoopUiOps glib_eventloops;
PurpleConversationUiOps null_conv_uiops;
PurpleCoreUiOps null_core_uiops;
guint glib_input_add(gint fd, PurpleInputCondition condition, PurpleInputFunction function, gpointer data);
gboolean purple_glib_io_invoke(GIOChannel *source, GIOCondition condition, gpointer data);	
void connect_to_signals_for_demonstration_purposes_only();
void null_write_conv(PurpleConversation *conv, const char *who, const char *alias,const char *message, PurpleMessageFlags flags, time_t mtime);
void null_ui_init();
//End Purple
@end
