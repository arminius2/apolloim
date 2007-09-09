#import <Foundation/Foundation.h>
#import "ApolloNotificationController.h"
#import "Buddy.h"
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

typedef enum {ApolloCORE_DISCONNECTED, ApolloCORE_CONNECTING, ApolloCORE_CONNECTED} ApolloCORE_ConnectionStatus;
@interface ApolloCore : NSObject
{
    ApolloCORE_ConnectionStatus connected;
	
	Acct* thisAccount;
	id _delegate;
	
	int num;
	GList *iter;
	GList *names;
	const char *prpl;
	GMainLoop *loop;
	PurpleAccount *purple_account;
	PurpleSavedStatus *status;	
}

+ (void)initialize;
+ (id)sharedInstance;

- (id)init;
- (void)setDelegate:(id)delegate;

- (void)createConnection:(Acct*)account;
- (void)destroyConnection:(Acct*)account;  

- (void)sendIM:(NSString*)body     toBuddy:(Buddy*)buddy;
- (void)receivedMessage:(NSString*)message fromUser:(Buddy*)user;

- (Acct*)thisAccount;

//Purple
static PurpleEventLoopUiOps			glib_eventloops;
static PurpleConversationUiOps		apollo_conv_uiops;
static PurpleCoreUiOps				apollo_core_uiops;

static void init_libpurple();
static void signed_on(PurpleConnection *gc, gpointer event);
static void signed_off(PurpleConnection *gc, gpointer event);
static void connect_to_signals();  //registers callbacks

static guint glib_input_add(gint fd, PurpleInputCondition condition, PurpleInputFunction function, gpointer data); //purple
static gboolean purple_glib_io_invoke(GIOChannel *source, GIOCondition condition, gpointer data);	 //purple
static void purple_glib_io_destroy(gpointer data);  //purple

static void apollo_write_conv(PurpleConversation *conv, const char *who, const char *alias,const char *message, PurpleMessageFlags flags, time_t mtime);
static void apollo_ui_init();

//Purple

/*- (ApolloIM_Connection*)findConnection:(Acct*)account; 

- (void)sendIMFromAcct:(Acct*)account toBuddy:  (Buddy*)buddy     withMessage:(NSString*)message;
- (void)recvIMFromAcct:(Acct*)account fromBuddy:(Buddy*)buddy     withMessage:(NSString*)message;

- (void)buddyEventFrom:(Acct*)account fromBuddy:(Buddy*)buddy     withEvent:(int)event;  *///Away/Back

- (void)dealloc;

@end
